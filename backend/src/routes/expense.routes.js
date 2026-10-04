const express          = require('express');
const expenseController = require('../controllers/expense.controller');
const { protect }       = require('../middleware/auth.middleware');

/**
 * Expense Routes — WeTravel Backend
 * Layer: Routes
 * Mounted at: /api/trips/:tripId/expenses  (mergeParams: true → :tripId available)
 *
 * ┌─────────────────────────────────────────────────────────────────────────────┐
 * │ Route                                        Method  Auth       Who         │
 * ├─────────────────────────────────────────────────────────────────────────────┤
 * │ /imagekit-auth                               GET     Member     Any member  │
 * │ /summary/me                                  GET     Member     Self        │
 * │ /ledger                                      GET     Member     Any member  │
 * │ /settlements                                 GET     Member     Any member  │
 * │ /settlements/calculate                       POST    Admin      Admin only  │
 * │ /settlements/:settlementId/complete          PATCH   Member*    Payer/Admin │
 * │ /                                            POST    Member     Any member  │
 * │ /                                            GET     Member     Any member  │
 * │ /:expenseId                                  GET     Member     Any member  │
 * │ /:expenseId/approve                          PATCH   Admin      Admin only  │
 * │ /:expenseId/reject                           PATCH   Admin      Admin only  │
 * └─────────────────────────────────────────────────────────────────────────────┘
 *
 * ⚠️  Route ordering matters — static segments (/imagekit-auth, /summary/me,
 *     /ledger, /settlements/…) MUST come before dynamic /:expenseId segments.
 */

const router = express.Router({ mergeParams: true }); // gives access to :tripId
router.use(protect); // ALL expense routes require authentication

// ── Static paths first (must precede /:expenseId) ────────────────────────────

// ImageKit direct-upload auth token for receipt photos
router.get('/imagekit-auth',                             expenseController.getImageKitAuth);

// Personal ledger: "my payments" vs "my expenses"
router.get('/summary/me',                                expenseController.getMyExpenseSummary);

// Full group ledger: per-member totals + group grand total
router.get('/ledger',                                    expenseController.getGroupLedger);

// Settlement plan: who pays whom how much
router.get('/settlements',                               expenseController.getSettlements);

// Admin recalculates and stores the minimum-transaction settlement plan
router.post('/settlements/calculate',                    expenseController.calculateSettlements);

// Mark a single settlement transaction as completed (payment made)
router.patch('/settlements/:settlementId/complete',      expenseController.completeSettlement);

// ── Collection routes ─────────────────────────────────────────────────────────

// Submit a new expense (manual amount OR receipt image for OCR)
router.post('/',                                         expenseController.createExpense);

// List all expenses; optional ?status=pending_approval|approved|rejected
router.get('/',                                          expenseController.getGroupExpenses);

// ── Dynamic /:expenseId routes ────────────────────────────────────────────────

// Share expense into trip chat room with payer automatically tagged
router.post('/:expenseId/discuss',                       expenseController.discussExpense);

// Get full detail of one expense
router.get('/:expenseId',                                expenseController.getExpenseById);

// Admin updates an expense (alter amount, description, category, or split members)
router.put('/:expenseId',                                expenseController.updateExpense);

// Admin deletes an expense
router.delete('/:expenseId',                             expenseController.deleteExpense);

// Admin approves a pending expense
router.patch('/:expenseId/approve',                      expenseController.approveExpense);

// Admin rejects a pending or approved expense
router.patch('/:expenseId/reject',                       expenseController.rejectExpense);

module.exports = router;
