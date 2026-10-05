import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class CreateExpenseUseCase {
  final ExpenseRepository repository;

  CreateExpenseUseCase(this.repository);

  Future<ExpenseEntity> call({
    required String tripId,
    double? amount,
    String? description,
    String? category,
    String? receiptImageUrl,
    List<String>? splitMemberIds,
  }) {
    return repository.createExpense(
      tripId: tripId,
      amount: amount,
      description: description,
      category: category,
      receiptImageUrl: receiptImageUrl,
      splitMemberIds: splitMemberIds,
    );
  }
}
