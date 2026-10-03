const expenseService = require('../services/expense.service');

// Expense controller handling expense creation, approvals, ledger summaries, and settlements

// GET /api/trips/:tripId/expenses/imagekit-auth
const getImageKitAuth = async (req, res, next) => {
  try {
    const params = await expenseService.getImageKitAuth(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: params });
  } catch (err) { next(err); }
};

// POST /api/trips/:tripId/expenses — manual entry or OCR upload
const createExpense = async (req, res, next) => {
  try {
    const { amount, description, category, receiptImageUrl, splitMemberIds, currency } = req.body;

    if (!amount && !receiptImageUrl) {
      return res.status(400).json({
        status:  'error',
        message: 'Provide either an amount (manual entry) or a receiptImageUrl (OCR upload).',
      });
    }

    if (amount && isNaN(parseFloat(amount))) {
      return res.status(400).json({ status: 'error', message: 'amount must be a valid number.' });
    }

    const expense = await expenseService.createExpense(req.user.id, req.params.tripId, {
      amount, description, category, receiptImageUrl, splitMemberIds, currency,
    });

    const isOcr = !!receiptImageUrl && !amount;
    res.status(201).json({
      status:  'success',
      message: isOcr
        ? 'Expense submitted. OCR is running in the background — you will be notified via WebSocket (EXPENSE_OCR_COMPLETED) when the amount is extracted.'
        : 'Expense submitted and auto-approved.',
      data: { expense },
    });
  } catch (err) { next(err); }
};

// GET /api/trips/:tripId/expenses?status=pending_approval|approved|rejected
const getGroupExpenses = async (req, res, next) => {
  try {
    const expenses = await expenseService.getGroupExpenses(
      req.user.id, req.params.tripId, req.query.status,
    );
    res.status(200).json({ status: 'success', data: { expenses } });
  } catch (err) { next(err); }
};

// GET /api/trips/:tripId/expenses/:expenseId
const getExpenseById = async (req, res, next) => {
  try {
    const expense = await expenseService.getExpenseById(
      req.user.id, req.params.tripId, req.params.expenseId,
    );
    res.status(200).json({ status: 'success', data: { expense } });
  } catch (err) { next(err); }
};

// PUT /api/trips/:tripId/expenses/:expenseId — admin update expense
const updateExpense = async (req, res, next) => {
  try {
    const { amount, description, category, splitMemberIds } = req.body;
    if (amount && isNaN(parseFloat(amount))) {
      return res.status(400).json({ status: 'error', message: 'amount must be a valid number.' });
    }
    const expense = await expenseService.updateExpenseByAdmin(
      req.user.id, req.params.tripId, req.params.expenseId, {
        amount, description, category, splitMemberIds,
      },
    );
    res.status(200).json({ status: 'success', message: 'Expense updated successfully.', data: { expense } });
  } catch (err) { next(err); }
};

// DELETE /api/trips/:tripId/expenses/:expenseId — admin delete expense
const deleteExpense = async (req, res, next) => {
  try {
    const result = await expenseService.deleteExpenseByAdmin(
      req.user.id, req.params.tripId, req.params.expenseId,
    );
    res.status(200).json({ status: 'success', message: result.message });
  } catch (err) { next(err); }
};

// POST /api/trips/:tripId/expenses/:expenseId/discuss — share expense into chat with tagged payer
const discussExpense = async (req, res, next) => {
  try {
    const { message } = req.body;
    const result = await expenseService.shareExpenseToChat(
      req.user.id, req.params.tripId, req.params.expenseId, { message },
    );
    res.status(200).json({
      status: 'success',
      message: 'Expense shared to group chat with payer automatically tagged.',
      data: result,
    });
  } catch (err) { next(err); }
};

// PATCH /api/trips/:tripId/expenses/:expenseId/approve — admin approve expense
const approveExpense = async (req, res, next) => {
  try {
    const expense = await expenseService.approveExpense(
      req.user.id, req.params.tripId, req.params.expenseId,
    );
    res.status(200).json({ status: 'success', message: 'Expense approved.', data: { expense } });
  } catch (err) { next(err); }
};

// PATCH /api/trips/:tripId/expenses/:expenseId/reject — admin reject expense
const rejectExpense = async (req, res, next) => {
  try {
    const expense = await expenseService.rejectExpense(
      req.user.id, req.params.tripId, req.params.expenseId,
    );
    res.status(200).json({ status: 'success', message: 'Expense rejected.', data: { expense } });
  } catch (err) { next(err); }
};

// GET /api/trips/:tripId/expenses/summary/me — personal ledger summary
const getMyExpenseSummary = async (req, res, next) => {
  try {
    const summary = await expenseService.getMyExpenseSummary(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { summary } });
  } catch (err) { next(err); }
};

// GET /api/trips/:tripId/expenses/ledger — group ledger with per-member balances
const getGroupLedger = async (req, res, next) => {
  try {
    const ledger = await expenseService.getGroupLedger(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { ledger } });
  } catch (err) { next(err); }
};

// POST /api/trips/:tripId/expenses/settlements/calculate — calculate debt settlements
const calculateSettlements = async (req, res, next) => {
  try {
    const settlements = await expenseService.calculateAndSaveSettlements(
      req.user.id, req.params.tripId,
    );
    res.status(200).json({
      status:  'success',
      message: `${settlements.length} settlement transaction(s) calculated.`,
      data:    { settlements },
    });
  } catch (err) { next(err); }
};

// GET /api/trips/:tripId/expenses/settlements — list settlement transactions
const getSettlements = async (req, res, next) => {
  try {
    const settlements = await expenseService.getSettlements(req.user.id, req.params.tripId);
    res.status(200).json({ status: 'success', data: { settlements } });
  } catch (err) { next(err); }
};

// PATCH /api/trips/:tripId/expenses/settlements/:settlementId/complete — mark settlement completed
const completeSettlement = async (req, res, next) => {
  try {
    const settlement = await expenseService.completeSettlement(
      req.user.id, req.params.tripId, req.params.settlementId,
    );
    res.status(200).json({ status: 'success', message: 'Settlement marked as completed.', data: { settlement } });
  } catch (err) { next(err); }
};

module.exports = {
  getImageKitAuth,
  createExpense,
  getGroupExpenses,
  getExpenseById,
  updateExpense,
  deleteExpense,
  discussExpense,
  approveExpense,
  rejectExpense,
  getMyExpenseSummary,
  getGroupLedger,
  calculateSettlements,
  getSettlements,
  completeSettlement,
};
