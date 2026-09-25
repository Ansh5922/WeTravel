const prisma = require('./prisma.client');

/**
 * Expense Repository — WeTravel Backend
 * Layer: Repository → DB
 * Handles all DB queries for expenses, expense_splits, and settlements.
 */

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Standard include block reused across all expense queries */
const expenseInclude = {
  creator:  { select: { id: true, fullName: true, username: true } },
  approver: { select: { id: true, fullName: true, username: true } },
  splits: {
    include: { user: { select: { id: true, fullName: true, username: true } } },
  },
};

/**
 * Compute equal split amounts, absorbing any rounding difference in the last slot.
 * @param {number} totalAmount
 * @param {string[]} memberIds
 * @returns {{ userId: string, amountOwed: number }[]}
 */
const buildEqualSplits = (totalAmount, memberIds) => {
  const n = memberIds.length;
  if (n === 0) return [];
  const perPerson = parseFloat((totalAmount / n).toFixed(2));
  return memberIds.map((userId, idx) => ({
    userId,
    amountOwed:
      idx === n - 1
        ? parseFloat((totalAmount - perPerson * (n - 1)).toFixed(2)) // absorb rounding
        : perPerson,
  }));
};

// ── Expense CRUD ──────────────────────────────────────────────────────────────

/**
 * Create a new expense.
 *
 * For manual_entry: amount is known → splits are created immediately.
 * For ai_screenshot_ocr: amount is null → splitMemberIds are stored in
 *   ocrRawMetadata.pendingSplitMemberIds so they can be used once the AI returns.
 */
const createExpense = async ({
  groupId, createdBy, source, amount, currency,
  category, description, receiptImageUrl, splitMemberIds,
}) => {
  const isOcr = source === 'ai_screenshot_ocr';
  const parsedAmount = amount ? parseFloat(amount) : null;

  return prisma.expense.create({
    data: {
      groupId,
      createdBy,
      source:          source   || 'manual_entry',
      amount:          parsedAmount,
      currency:        currency || 'INR',
      category:        category || null,
      description:     description || null,
      receiptImageUrl: receiptImageUrl || null,
      status:          isOcr ? 'pending_approval' : 'approved',
      // For OCR flow: store the chosen split members for later resolution
      ocrRawMetadata: isOcr
        ? { pendingSplitMemberIds: splitMemberIds || [] }
        : null,
      // For manual flow: create splits immediately
      splits: (!isOcr && parsedAmount && splitMemberIds?.length > 0) ? {
        create: buildEqualSplits(parsedAmount, splitMemberIds),
      } : undefined,
    },
    include: expenseInclude,
  });
};

/**
 * Update an expense after the AI OCR service has returned an amount.
 * Reads pendingSplitMemberIds from ocrRawMetadata, creates splits, and marks approved.
 */
const updateExpenseAfterOcr = async (expenseId, { amount, category, ocrRawText }) => {
  // Fetch current metadata to retrieve the stored member IDs
  const existing = await prisma.expense.findUnique({
    where:  { id: expenseId },
    select: { ocrRawMetadata: true },
  });

  const pendingIds = existing?.ocrRawMetadata?.pendingSplitMemberIds ?? [];
  const parsedAmount = parseFloat(amount);

  // Update expense record — auto-approve if valid amount extracted
  await prisma.expense.update({
    where: { id: expenseId },
    data: {
      amount:         parsedAmount,
      category:       category || null,
      status:         parsedAmount ? 'approved' : 'pending_approval',
      ocrRawMetadata: { ocrExtractedAmount: parsedAmount, rawText: ocrRawText || null },
    },
  });

  // Create the splits now that the amount is resolved
  if (pendingIds.length > 0) {
    await prisma.expenseSplit.deleteMany({ where: { expenseId } }); // idempotent
    await prisma.expenseSplit.createMany({
      data: buildEqualSplits(parsedAmount, pendingIds).map((s) => ({
        expenseId, ...s,
      })),
    });
  }

  return prisma.expense.findUnique({ where: { id: expenseId }, include: expenseInclude });
};

/** Admin modifies an expense (amount, description, category, and/or splits) */
const updateExpense = async (expenseId, { amount, description, category, splitMemberIds }) => {
  const data = {};
  if (description !== undefined) data.description = description;
  if (category !== undefined) data.category = category;

  if (amount !== undefined) {
    data.amount = parseFloat(amount);
  }

  const updated = await prisma.expense.update({
    where: { id: expenseId },
    data,
  });

  if (splitMemberIds || amount !== undefined) {
    const existingSplits = await prisma.expenseSplit.findMany({ where: { expenseId } });
    const finalMemberIds = splitMemberIds && splitMemberIds.length > 0
      ? splitMemberIds
      : existingSplits.map((s) => s.userId);
    const finalAmount = amount !== undefined ? parseFloat(amount) : Number(updated.amount);

    if (finalAmount && finalMemberIds.length > 0) {
      await prisma.expenseSplit.deleteMany({ where: { expenseId } });
      await prisma.expenseSplit.createMany({
        data: buildEqualSplits(finalAmount, finalMemberIds).map((s) => ({
          expenseId,
          ...s,
        })),
      });
    }
  }

  return prisma.expense.findUnique({ where: { id: expenseId }, include: expenseInclude });
};

/** Admin deletes an expense */
const deleteExpense = async (expenseId) => {
  return prisma.expense.delete({
    where: { id: expenseId },
  });
};

/** Admin approves an expense */
const approveExpense = async (expenseId, approvedBy) =>
  prisma.expense.update({
    where: { id: expenseId },
    data: { status: 'approved', approvedBy, approvedAt: new Date() },
    include: expenseInclude,
  });

/** Admin rejects an expense */
const rejectExpense = async (expenseId, approvedBy) =>
  prisma.expense.update({
    where: { id: expenseId },
    data: { status: 'rejected', approvedBy, approvedAt: new Date() },
    include: expenseInclude,
  });

/** Fetch all expenses for a trip, optionally filtered by status */
const getGroupExpenses = async (groupId, status) => {
  const where = { groupId };
  if (status) where.status = status;
  return prisma.expense.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    include: expenseInclude,
  });
};

/** Fetch a single expense by ID */
const getExpenseById = async (expenseId) =>
  prisma.expense.findUnique({ where: { id: expenseId }, include: expenseInclude });

/** Fetch only approved expenses — used for ledger and settlement calculations */
const getApprovedExpenses = async (groupId) =>
  prisma.expense.findMany({
    where:   { groupId, status: 'approved' },
    include: { splits: true },
  });

/** Fetch all group members (userId + display name) */
const getGroupMembers = async (groupId) =>
  prisma.groupMember.findMany({
    where:   { groupId },
    include: { user: { select: { id: true, fullName: true, username: true } } },
  });

// ── Settlements ───────────────────────────────────────────────────────────────

/**
 * Atomically replace all pending settlements for the group with a fresh calculation.
 * Completed settlements are never touched.
 */
const saveSettlements = async (groupId, settlements) => {
  await prisma.settlement.deleteMany({ where: { groupId, status: 'pending' } });
  if (settlements.length === 0) return [];

  await prisma.settlement.createMany({
    data: settlements.map((s) => ({
      groupId,
      payerId: s.payerId,
      payeeId: s.payeeId,
      amount:  s.amount,
      status:  'pending',
    })),
  });

  return prisma.settlement.findMany({
    where:   { groupId },
    include: {
      payer: { select: { id: true, fullName: true, username: true } },
      payee: { select: { id: true, fullName: true, username: true } },
    },
    orderBy: { amount: 'desc' },
  });
};

/** Fetch all settlements (pending + completed) for a trip */
const getSettlements = async (groupId) =>
  prisma.settlement.findMany({
    where:   { groupId },
    include: {
      payer: { select: { id: true, fullName: true, username: true } },
      payee: { select: { id: true, fullName: true, username: true } },
    },
    orderBy: { amount: 'desc' },
  });

/** Mark a settlement as completed (payer has paid) */
const completeSettlement = async (settlementId, groupId) =>
  prisma.settlement.update({
    where: { id: settlementId, groupId },       // scoped to group for safety
    data:  { status: 'completed' },
    include: {
      payer: { select: { id: true, fullName: true, username: true } },
      payee: { select: { id: true, fullName: true, username: true } },
    },
  });

module.exports = {
  createExpense,
  updateExpenseAfterOcr,
  updateExpense,
  deleteExpense,
  approveExpense,
  rejectExpense,
  getGroupExpenses,
  getExpenseById,
  getApprovedExpenses,
  getGroupMembers,
  saveSettlements,
  getSettlements,
  completeSettlement,
};
