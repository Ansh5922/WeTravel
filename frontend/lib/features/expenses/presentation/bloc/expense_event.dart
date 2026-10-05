import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class ExpensesFetchRequested extends ExpenseEvent {
  final String tripId;
  final String? statusFilter;

  const ExpensesFetchRequested({
    required this.tripId,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [tripId, statusFilter];
}

class ExpenseCreateRequested extends ExpenseEvent {
  final String tripId;
  final double? amount;
  final String? description;
  final String? category;
  final String? receiptImageUrl;
  final List<String>? splitMemberIds;

  const ExpenseCreateRequested({
    required this.tripId,
    this.amount,
    this.description,
    this.category,
    this.receiptImageUrl,
    this.splitMemberIds,
  });

  @override
  List<Object?> get props => [
        tripId,
        amount,
        description,
        category,
        receiptImageUrl,
        splitMemberIds,
      ];
}

class GroupLedgerRequested extends ExpenseEvent {
  final String tripId;

  const GroupLedgerRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class SettlementsRequested extends ExpenseEvent {
  final String tripId;

  const SettlementsRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}
