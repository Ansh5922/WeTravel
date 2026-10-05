import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String groupId;
  final String paidByUserId;
  final String paidByUsername;
  final String paidByFullName;
  final double amount;
  final String description;
  final String category;
  final String status; // 'pending_approval', 'approved', 'rejected'
  final String? receiptImageUrl;
  final List<String> splitMemberIds;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.paidByUsername,
    required this.paidByFullName,
    required this.amount,
    required this.description,
    required this.category,
    required this.status,
    this.receiptImageUrl,
    required this.splitMemberIds,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        paidByUserId,
        paidByUsername,
        paidByFullName,
        amount,
        description,
        category,
        status,
        receiptImageUrl,
        splitMemberIds,
        createdAt,
      ];
}

class ExpenseLedgerEntity extends Equatable {
  final double grandTotal;
  final double myPaidAmount;
  final double myShareAmount;
  final double myBalance; // positive = owed money, negative = owes money

  const ExpenseLedgerEntity({
    required this.grandTotal,
    required this.myPaidAmount,
    required this.myShareAmount,
    required this.myBalance,
  });

  @override
  List<Object?> get props => [grandTotal, myPaidAmount, myShareAmount, myBalance];
}

class ExpenseSettlementEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;
  final bool isCompleted;

  const ExpenseSettlementEntity({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        fromUserName,
        toUserId,
        toUserName,
        amount,
        isCompleted,
      ];
}
