import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class ScanReceiptUseCase {
  final ExpenseRepository repository;

  ScanReceiptUseCase({required this.repository});

  Future<ReceiptScanEntity> call({
    required String tripId,
    required String receiptImageUrl,
  }) {
    return repository.scanReceipt(tripId, receiptImageUrl);
  }
}
