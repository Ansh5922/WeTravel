import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetSettlementsUseCase {
  final ExpenseRepository repository;

  GetSettlementsUseCase(this.repository);

  Future<List<ExpenseSettlementEntity>> call(String tripId) {
    return repository.getSettlements(tripId);
  }
}
