import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getGroupExpenses(String tripId, {String? status});
  Future<ExpenseEntity> createExpense({
    required String tripId,
    double? amount,
    String? description,
    String? category,
    String? receiptImageUrl,
    List<String>? splitMemberIds,
  });
  Future<ExpenseLedgerEntity> getGroupLedger(String tripId);
  Future<List<ExpenseSettlementEntity>> getSettlements(String tripId);
}
