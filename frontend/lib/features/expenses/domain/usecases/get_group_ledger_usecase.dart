import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetGroupLedgerUseCase {
  final ExpenseRepository repository;

  GetGroupLedgerUseCase(this.repository);

  Future<ExpenseLedgerEntity> call(String tripId) {
    return repository.getGroupLedger(tripId);
  }
}
