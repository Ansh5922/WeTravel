import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ExpenseEntity>> getGroupExpenses(String tripId, {String? status}) {
    return remoteDataSource.getGroupExpenses(tripId, status: status);
  }

  @override
  Future<ExpenseEntity> createExpense({
    required String tripId,
    double? amount,
    String? description,
    String? category,
    String? receiptImageUrl,
    List<String>? splitMemberIds,
  }) {
    return remoteDataSource.createExpense(
      tripId: tripId,
      amount: amount,
      description: description,
      category: category,
      receiptImageUrl: receiptImageUrl,
      splitMemberIds: splitMemberIds,
    );
  }

  @override
  Future<ExpenseLedgerEntity> getGroupLedger(String tripId) {
    return remoteDataSource.getGroupLedger(tripId);
  }

  @override
  Future<List<ExpenseSettlementEntity>> getSettlements(String tripId) {
    return remoteDataSource.getSettlements(tripId);
  }
}
