const jwt       = require('jsonwebtoken');
const prisma     = require('../repositories/prisma.client');
const expenseRepo = require('../repositories/expense.repository');
const chatRepo    = require('../repositories/chat.repository');
const imagekitService = require('./imagekit.service');
const { rooms }     = require('../websocket/ws.server');
const { broadcast } = require('../websocket/ws.handler');

/**
 * Expense Service — WeTravel Backend
 * Layer: Service (business logic for expense vault)
 * Architecture: Routes → Controller → Service → Repository → DB
 *
 * ──────────────────────────────────────────────────────────────
 * SETTLEMENT ALGORITHM  (Min-Cash-Flow / Ascending-payment sort)
 * ──────────────────────────────────────────────────────────────
 * For every approved expense:
 *   - The creator (payer) gets credited the full amount.
 *   - Each split member gets debited their amountOwed.
 *
 * netBalance = totalPaid - totalOwed
 *   > 0  → creditor (others owe them money)
 *   < 0  → debtor   (they owe others money)
 *
 * Sorting ascending by payments made places the lowest-paying
 * members first.  The greedy matching then settles the member
 * who owes the most to the member who is owed the most, reducing
 * the total number of transactions to the theoretical minimum.
 */

const AI_URL = () => process.env.AI_SERVICE_URL || 'http://localhost:8000';

/** Build a short-lived internal JWT (fire-and-forget calls to FastAPI) */
const makeInternalToken = () =>
  jwt.sign({ sub: 'internal-service' }, process.env.JWT_SECRET, { expiresIn: '5m' });

/** Verify that a user is a member of a trip (throws 403 otherwise) */
const requireMembership = async (userId, groupId) => {
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  if (!member) throw Object.assign(new Error('You are not a member of this trip.'), { statusCode: 403 });
  return member;
};

/** Verify admin/creator role — used for approve/reject and settlement recalc */
const requireAdmin = async (userId, groupId) => {
  const member = await requireMembership(userId, groupId);
  if (member.role === 'member') {
    throw Object.assign(new Error('Only a trip admin can perform this action.'), { statusCode: 403 });
  }
  return member;
};

// ── ImageKit Auth (re-used for receipt photo uploads) ─────────────────────────

const getImageKitAuth = async (userId, groupId) => {
  await requireMembership(userId, groupId);
  return imagekitService.getAuthParams();
};

// ── Create Expense ────────────────────────────────────────────────────────────

/**
 * Any group member can submit an expense.
 *
 * @param {string} userId    - The authenticated user (assumed to be the payer).
 * @param {string} groupId
 * @param {{ amount?, description, category, receiptImageUrl?, splitMemberIds? }} body
 *
 * Flow (manual):  amount provided → splits created immediately.
 * Flow (OCR):     receiptImageUrl provided, no amount → splits stored as
 *                 pending in ocrRawMetadata; AI call fires in background.
 */
const createExpense = async (userId, groupId, {
  amount, description, category, receiptImageUrl, splitMemberIds, currency,
}) => {
  await requireMembership(userId, groupId);

  // Resolve split targets: default to all current group members
  let targetIds = splitMemberIds;
  if (!targetIds || targetIds.length === 0) {
    const members = await expenseRepo.getGroupMembers(groupId);
    targetIds = members.map((m) => m.userId);
  }

  const isOcr = !!receiptImageUrl && !amount;

  const expense = await expenseRepo.createExpense({
    groupId,
    createdBy:       userId,
    source:          isOcr ? 'ai_screenshot_ocr' : 'manual_entry',
    amount:          amount  || null,
    currency:        currency || 'INR',
    category:        category || null,
    description:     description || null,
    receiptImageUrl: receiptImageUrl || null,
    splitMemberIds:  targetIds,
  });

  // For OCR uploads: fire-and-forget call to AI server in the background.
  // The HTTP response (201) is returned to the client *before* OCR completes.
  if (isOcr) {
    _fireOcrRequest(expense.id, receiptImageUrl, groupId);
  }

  return expense;
};

/**
 * Background fire-and-forget: calls FastAPI OCR endpoint, then updates the
 * expense record and broadcasts a WebSocket event to the trip room.
 */
const _fireOcrRequest = (expenseId, imageUrl, groupId) => {
  const token = makeInternalToken();

  fetch(`${AI_URL()}/api/ai/ocr/receipt`, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body:    JSON.stringify({ expense_id: expenseId, image_url: imageUrl, group_id: groupId }),
  })
    .then(async (res) => {
      if (!res.ok) {
        const body = await res.text();
        console.error(`[OCR] ❌ Failed for expense ${expenseId}: ${res.status} — ${body}`);
        return;
      }
      const data = await res.json();

      if (!data.amount) {
        console.warn(`[OCR] ⚠️  No amount extracted for expense ${expenseId}. Manual entry required.`);
        return;
      }

      // Update expense with extracted amount + recreate splits
      const updated = await expenseRepo.updateExpenseAfterOcr(expenseId, {
        amount:     data.amount,
        category:   data.category || null,
        ocrRawText: data.raw_text || null,
      });

      // Notify all clients in the trip room
      broadcast(rooms, groupId, {
        type:      'EXPENSE_OCR_COMPLETED',
        expenseId: expenseId,
        amount:    data.amount,
        category:  data.category,
        expense:   updated,
      });

      console.log(`[OCR] ✅ Expense ${expenseId} updated — amount: ₹${data.amount}`);
    })
    .catch((err) =>
      console.error(`[OCR] Network error for expense ${expenseId}:`, err.message),
    );
};

// ── Read Expenses ─────────────────────────────────────────────────────────────

/** Any group member can list all expenses (optionally filtered by status) */
const getGroupExpenses = async (userId, groupId, status) => {
  await requireMembership(userId, groupId);
  return expenseRepo.getGroupExpenses(groupId, status || undefined);
};

/** Any group member can view a single expense */
const getExpenseById = async (userId, groupId, expenseId) => {
  await requireMembership(userId, groupId);
  const expense = await expenseRepo.getExpenseById(expenseId);
  if (!expense || expense.groupId !== groupId) {
    throw Object.assign(new Error('Expense not found.'), { statusCode: 404 });
  }
  return expense;
};

// ── Admin Actions ─────────────────────────────────────────────────────────────

/** Admin approves a pending expense */
const approveExpense = async (userId, groupId, expenseId) => {
  await requireAdmin(userId, groupId);
  const expense = await expenseRepo.getExpenseById(expenseId);
  if (!expense || expense.groupId !== groupId) {
    throw Object.assign(new Error('Expense not found.'), { statusCode: 404 });
  }
  if (expense.status !== 'pending_approval') {
    throw Object.assign(
      new Error(`Expense is already ${expense.status} and cannot be approved again.`),
      { statusCode: 400 },
    );
  }
  if (!expense.amount) {
    throw Object.assign(
      new Error('Cannot approve an expense with no amount. Wait for OCR to complete or enter amount manually.'),
      { statusCode: 400 },
    );
  }
  return expenseRepo.approveExpense(expenseId, userId);
};

/** Admin rejects a pending expense */
const rejectExpense = async (userId, groupId, expenseId) => {
  await requireAdmin(userId, groupId);
  const expense = await expenseRepo.getExpenseById(expenseId);
  if (!expense || expense.groupId !== groupId) {
    throw Object.assign(new Error('Expense not found.'), { statusCode: 404 });
  }
  if (expense.status === 'rejected') {
    throw Object.assign(new Error('Expense is already rejected.'), { statusCode: 400 });
  }
  return expenseRepo.rejectExpense(expenseId, userId);
};

// ── Ledger Summaries ──────────────────────────────────────────────────────────

/**
 * Build per-member ledger stats from approved expenses.
 *
 * @param {object[]} expenses  Approved expenses with splits
 * @param {object[]} members   All group members
 * @returns {object[]} Array of { userId, user, totalPaid, totalOwed, netBalance }
 */
const _buildLedger = (expenses, members) => {
  const paid  = {}; // userId → sum of amounts the user paid (created)
  const owed  = {}; // userId → sum of amounts the user owes (splits)

  members.forEach(({ userId }) => { paid[userId] = 0; owed[userId] = 0; });

  expenses.forEach((exp) => {
    const amount = parseFloat(exp.amount ?? 0);
    // Credit the payer
    if (paid[exp.createdBy] !== undefined) paid[exp.createdBy] += amount;

    // Debit each split member
    exp.splits.forEach((split) => {
      if (owed[split.userId] !== undefined) {
        owed[split.userId] += parseFloat(split.amountOwed);
      }
    });
  });

  return members.map(({ userId, user }) => ({
    userId,
    user,
    totalPaid:  parseFloat(paid[userId].toFixed(2)),
    totalOwed:  parseFloat(owed[userId].toFixed(2)),
    netBalance: parseFloat((paid[userId] - owed[userId]).toFixed(2)),
  }));
};

/** Returns ledger summary for the requesting user only */
const getMyExpenseSummary = async (userId, groupId) => {
  await requireMembership(userId, groupId);
  const [expenses, members] = await Promise.all([
    expenseRepo.getApprovedExpenses(groupId),
    expenseRepo.getGroupMembers(groupId),
  ]);
  const ledger = _buildLedger(expenses, members);
  const mine = ledger.find((l) => l.userId === userId);
  return mine || { userId, totalPaid: 0, totalOwed: 0, netBalance: 0 };
};

/** Returns the full group ledger — all members (admin or any member can view) */
const getGroupLedger = async (userId, groupId) => {
  await requireMembership(userId, groupId);
  const [expenses, members] = await Promise.all([
    expenseRepo.getApprovedExpenses(groupId),
    expenseRepo.getGroupMembers(groupId),
  ]);
  const ledger = _buildLedger(expenses, members);
  const totalGroupExpense = parseFloat(
    expenses.reduce((sum, e) => sum + parseFloat(e.amount ?? 0), 0).toFixed(2),
  );
  return { totalGroupExpense, members: ledger };
};

// ── Settlement Calculation ────────────────────────────────────────────────────

/**
 * Min-cash-flow greedy algorithm.
 *
 * Steps (matching the user's description):
 *  1. Sort members by totalPaid ascending (lowest payer first).
 *  2. Separate into debtors (netBalance < 0) and creditors (netBalance > 0).
 *  3. Sort debtors descending by amount owed (highest debt first).
 *  4. Sort creditors descending by amount owed to them (most owed first).
 *  5. Greedily match: debtor[i] pays creditor[j] = min(debt, credit).
 *     Advance pointer when a side is fully settled.
 *
 * This minimises the number of transactions needed.
 */
const _calculateSettlements = (ledger) => {
  // Step 1 — sort ascending by payments (as described)
  const sorted = [...ledger].sort((a, b) => a.totalPaid - b.totalPaid);

  // Step 2 — split into creditors & debtors
  const creditors = sorted
    .filter((m) => m.netBalance > 0.01)
    .map((m) => ({ userId: m.userId, amount: m.netBalance }))
    .sort((a, b) => b.amount - a.amount); // descending — most owed first

  const debtors = sorted
    .filter((m) => m.netBalance < -0.01)
    .map((m) => ({ userId: m.userId, amount: -m.netBalance }))
    .sort((a, b) => b.amount - a.amount); // descending — biggest debt first

  const settlements = [];
  let i = 0;
  let j = 0;

  while (i < debtors.length && j < creditors.length) {
    const payAmount = Math.min(debtors[i].amount, creditors[j].amount);
    const rounded   = parseFloat(payAmount.toFixed(2));

    if (rounded > 0.01) {
      settlements.push({
        payerId: debtors[i].userId,   // person who owes
        payeeId: creditors[j].userId, // person who is owed
        amount:  rounded,
      });
    }

    debtors[i].amount   -= payAmount;
    creditors[j].amount -= payAmount;

    if (debtors[i].amount   < 0.01) i++;
    if (creditors[j].amount < 0.01) j++;
  }

  return settlements;
};

/**
 * Recalculate settlements for the group and persist them (admin only).
 * Replaces all existing pending settlements.
 */
const calculateAndSaveSettlements = async (userId, groupId) => {
  await requireAdmin(userId, groupId);
  const [expenses, members] = await Promise.all([
    expenseRepo.getApprovedExpenses(groupId),
    expenseRepo.getGroupMembers(groupId),
  ]);
  const ledger      = _buildLedger(expenses, members);
  const settlements = _calculateSettlements(ledger);
  return expenseRepo.saveSettlements(groupId, settlements);
};

/** Any member can view the current settlement plan */
const getSettlements = async (userId, groupId) => {
  await requireMembership(userId, groupId);
  return expenseRepo.getSettlements(groupId);
};

/** Mark a settlement as completed once payment is made */
const completeSettlement = async (userId, groupId, settlementId) => {
  await requireMembership(userId, groupId);
  const settlement = await prisma.settlement.findUnique({ where: { id: settlementId } });
  if (!settlement || settlement.groupId !== groupId) {
    throw Object.assign(new Error('Settlement not found.'), { statusCode: 404 });
  }
  // Only the payer themselves or an admin can mark it complete
  const member = await prisma.groupMember.findFirst({ where: { groupId, userId } });
  const isAdmin  = member?.role !== 'member';
  const isPayer  = settlement.payerId === userId;
  if (!isPayer && !isAdmin) {
    throw Object.assign(
      new Error('Only the payer or a trip admin can mark this settlement as completed.'),
      { statusCode: 403 },
    );
  }
  return expenseRepo.completeSettlement(settlementId, groupId);
};

// ── Admin Override & Modification ────────────────────────────────────────────

/**
 * Admin updates an existing expense (can alter amount, description, category, and members liable).
 */
const updateExpenseByAdmin = async (userId, groupId, expenseId, {
  amount, description, category, splitMemberIds,
}) => {
  await requireAdmin(userId, groupId);
  const expense = await expenseRepo.getExpenseById(expenseId);
  if (!expense || expense.groupId !== groupId) {
    throw Object.assign(new Error('Expense not found in this trip.'), { statusCode: 404 });
  }

  const updated = await expenseRepo.updateExpense(expenseId, {
    amount, description, category, splitMemberIds,
  });

  // Broadcast update via WebSocket to all members in trip room
  broadcast(rooms, groupId, {
    type: 'EXPENSE_UPDATED',
    tripId: groupId,
    expense: updated,
    updatedBy: userId,
  });

  return updated;
};

/**
 * Admin deletes an expense from the trip ledger.
 */
const deleteExpenseByAdmin = async (userId, groupId, expenseId) => {
  await requireAdmin(userId, groupId);
  const expense = await expenseRepo.getExpenseById(expenseId);
  if (!expense || expense.groupId !== groupId) {
    throw Object.assign(new Error('Expense not found in this trip.'), { statusCode: 404 });
  }

  await expenseRepo.deleteExpense(expenseId);

  // Broadcast deletion via WebSocket
  broadcast(rooms, groupId, {
    type: 'EXPENSE_DELETED',
    tripId: groupId,
    expenseId,
    deletedBy: userId,
  });

  return { message: 'Expense deleted successfully.' };
};

// ── Member Objection / Chat Discussion ───────────────────────────────────────

/**
 * A member who owes an expense (or any trip member) can share the payment
 * into the trip chat with a query/objection. The payer is automatically tagged.
 */
const shareExpenseToChat = async (userId, groupId, expenseId, { message }) => {
  await requireMembership(userId, groupId);

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, fullName: true, username: true },
  });

  const expense = await expenseRepo.getExpenseById(expenseId);
  if (!expense || expense.groupId !== groupId) {
    throw Object.assign(new Error('Expense not found in this trip.'), { statusCode: 404 });
  }

  // Identify payer (the one who actually made the payment)
  const payer = expense.creator;
  const payerTag = payer?.username ? `@${payer.username}` : `@${payer?.fullName || 'payer'}`;

  // Find user's split if they were part of this expense
  const userSplit = expense.splits?.find((s) => s.userId === userId);
  const userShareText = userSplit
    ? ` (My share: ₹${Number(userSplit.amountOwed).toFixed(2)})`
    : '';
  const note = message && message.trim() ? message.trim() : 'I have a question regarding this expense.';

  // Build the tagged chat message
  const formattedContent = `${payerTag} 🧾 Objection/Query regarding "${expense.description || 'Payment'}" (Total: ₹${Number(expense.amount || 0).toFixed(2)}${userShareText}):\n"${note}"`;

  // Save the message in the group chat
  const savedMessage = await chatRepo.saveMessage({
    groupId,
    senderId: userId,
    messageType: 'text',
    content: formattedContent,
    imageUrl: expense.receiptImageUrl || null,
  });

  // 1. Broadcast standard chat message so it appears immediately in the chat tab
  broadcast(rooms, groupId, {
    type: 'message',
    id: savedMessage.id,
    sender: { id: user.id, fullName: user.fullName, username: user.username },
    content: savedMessage.content,
    imageUrl: savedMessage.imageUrl,
    createdAt: savedMessage.createdAt,
    expenseContext: {
      expenseId: expense.id,
      description: expense.description,
      totalAmount: expense.amount,
      payerId: payer?.id,
      payerName: payer?.fullName,
      receiptImageUrl: expense.receiptImageUrl,
    },
  });

  // 2. Broadcast expense disputed event for any open expense view/screen
  broadcast(rooms, groupId, {
    type: 'EXPENSE_DISPUTED',
    tripId: groupId,
    expenseId: expense.id,
    disputedBy: { id: user.id, fullName: user.fullName, username: user.username },
    payer: { id: payer?.id, fullName: payer?.fullName, username: payer?.username },
    note,
  });

  return {
    chatMessage: savedMessage,
    expense,
  };
};

module.exports = {
  getImageKitAuth,
  createExpense,
  getGroupExpenses,
  getExpenseById,
  updateExpenseByAdmin,
  deleteExpenseByAdmin,
  shareExpenseToChat,
  approveExpense,
  rejectExpense,
  getMyExpenseSummary,
  getGroupLedger,
  calculateAndSaveSettlements,
  getSettlements,
  completeSettlement,
};
