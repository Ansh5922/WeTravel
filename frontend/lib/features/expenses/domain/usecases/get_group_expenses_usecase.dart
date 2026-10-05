import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetGroupExpensesUseCase {
  final ExpenseRepository repository;

  GetGroupExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> call(String tripId, {String? status}) {
    return repository.getGroupExpenses(tripId, status: status);
  }
}
