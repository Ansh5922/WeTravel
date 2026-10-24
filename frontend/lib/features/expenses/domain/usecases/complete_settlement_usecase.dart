import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class CompleteSettlementUseCase {
  final ExpenseRepository repository;

  CompleteSettlementUseCase(this.repository);

  Future<ExpenseSettlementEntity> call({
    required String tripId,
    required String settlementId,
  }) {
    return repository.completeSettlement(tripId, settlementId);
  }
}
