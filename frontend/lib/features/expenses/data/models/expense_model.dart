import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.groupId,
    required super.paidByUserId,
    required super.paidByUsername,
    required super.paidByFullName,
    required super.amount,
    required super.description,
    required super.category,
    required super.status,
    super.receiptImageUrl,
    required super.splitMemberIds,
    required super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final payerObj = (json['creator'] is Map<String, dynamic>)
        ? json['creator'] as Map<String, dynamic>
        : (json['payer'] is Map<String, dynamic>)
            ? json['payer'] as Map<String, dynamic>
            : (json['paidBy'] is Map<String, dynamic>)
                ? json['paidBy'] as Map<String, dynamic>
                : (json['user'] is Map<String, dynamic>)
                    ? json['user'] as Map<String, dynamic>
                    : {};

    final splitsList = (json['splits'] as List<dynamic>?)
            ?.map((s) => (s is Map<String, dynamic>) ? s['userId']?.toString() ?? '' : s.toString())
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];

    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    final paidByUserId = json['paidByUserId']?.toString() ??
        json['createdBy']?.toString() ??
        json['paidById']?.toString() ??
        payerObj['id']?.toString() ??
        '';
    final paidByUsername = payerObj['username']?.toString() ?? json['paidByUsername']?.toString() ?? '';
    final paidByFullName = payerObj['fullName']?.toString() ??
        payerObj['name']?.toString() ??
        (paidByUsername.isNotEmpty ? paidByUsername : 'You');

    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      paidByUserId: paidByUserId,
      paidByUsername: paidByUsername,
      paidByFullName: paidByFullName,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '') ?? 0.0),
      description: json['description']?.toString() ?? 'Expense',
      category: json['category']?.toString() ?? 'General',
      status: json['status']?.toString() ?? 'approved',
      receiptImageUrl: json['receiptImageUrl']?.toString(),
      splitMemberIds: splitsList,
      createdAt: parsedDate,
    );
  }
}

class ExpenseLedgerModel extends ExpenseLedgerEntity {
  const ExpenseLedgerModel({
    required super.grandTotal,
    required super.myPaidAmount,
    required super.myShareAmount,
    required super.myBalance,
  });

  factory ExpenseLedgerModel.fromJson(Map<String, dynamic> json) {
    final root = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final dataObj = (root['ledger'] is Map<String, dynamic>)
        ? root['ledger'] as Map<String, dynamic>
        : (root['summary'] is Map<String, dynamic>)
            ? root['summary'] as Map<String, dynamic>
            : root;

    final grandTotalNum = dataObj['totalGroupExpense'] ?? dataObj['grandTotal'] ?? 0.0;
    final myPaidNum = dataObj['totalPaid'] ?? dataObj['myPaidAmount'] ?? 0.0;
    final myShareNum = dataObj['totalOwed'] ?? dataObj['myShareAmount'] ?? 0.0;
    final myBalanceNum = dataObj['netBalance'] ?? dataObj['myBalance'] ?? 0.0;

    return ExpenseLedgerModel(
      grandTotal: (grandTotalNum is num) ? grandTotalNum.toDouble() : double.tryParse(grandTotalNum.toString()) ?? 0.0,
      myPaidAmount: (myPaidNum is num) ? myPaidNum.toDouble() : double.tryParse(myPaidNum.toString()) ?? 0.0,
      myShareAmount: (myShareNum is num) ? myShareNum.toDouble() : double.tryParse(myShareNum.toString()) ?? 0.0,
      myBalance: (myBalanceNum is num) ? myBalanceNum.toDouble() : double.tryParse(myBalanceNum.toString()) ?? 0.0,
    );
  }
}

class ExpenseSettlementModel extends ExpenseSettlementEntity {
  const ExpenseSettlementModel({
    required super.id,
    required super.fromUserId,
    required super.fromUserName,
    required super.toUserId,
    required super.toUserName,
    required super.amount,
    required super.isCompleted,
  });

  factory ExpenseSettlementModel.fromJson(Map<String, dynamic> json) {
    final fromUser = (json['fromUser'] is Map<String, dynamic>) ? json['fromUser'] as Map<String, dynamic> : {};
    final toUser = (json['toUser'] is Map<String, dynamic>) ? json['toUser'] as Map<String, dynamic> : {};

    return ExpenseSettlementModel(
      id: json['id']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? fromUser['id']?.toString() ?? '',
      fromUserName: fromUser['fullName']?.toString() ?? fromUser['username']?.toString() ?? 'Payer',
      toUserId: json['toUserId']?.toString() ?? toUser['id']?.toString() ?? '',
      toUserName: toUser['fullName']?.toString() ?? toUser['username']?.toString() ?? 'Receiver',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : (double.tryParse(json['amount']?.toString() ?? '') ?? 0.0),
      isCompleted: json['isCompleted'] == true || json['status'] == 'completed',
    );
  }
}
