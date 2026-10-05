import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/expenses/data/models/expense_model.dart';
import 'package:frontend/features/expenses/domain/entities/expense_entity.dart';
import 'package:frontend/features/expenses/domain/repositories/expense_repository.dart';
import 'package:frontend/features/expenses/domain/usecases/create_expense_usecase.dart';
import 'package:frontend/features/expenses/domain/usecases/get_group_expenses_usecase.dart';
import 'package:frontend/features/expenses/domain/usecases/get_group_ledger_usecase.dart';
import 'package:frontend/features/expenses/domain/usecases/get_settlements_usecase.dart';
import 'package:frontend/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:frontend/features/expenses/presentation/bloc/expense_event.dart';
import 'package:frontend/features/expenses/presentation/bloc/expense_state.dart';

class FakeExpenseRepository implements ExpenseRepository {
  List<ExpenseEntity>? expensesToReturn;
  ExpenseLedgerEntity? ledgerToReturn;
  List<ExpenseSettlementEntity>? settlementsToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<ExpenseEntity>> getGroupExpenses(String tripId, {String? status}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return expensesToReturn ??
        [
          ExpenseEntity(
            id: 'exp_1',
            groupId: 'trip_10',
            paidByUserId: 'usr_1',
            paidByUsername: 'rashi',
            paidByFullName: 'Rashi',
            amount: 32000.0,
            description: 'Villa Stay',
            category: 'Accommodation',
            status: 'approved',
            splitMemberIds: const ['usr_1', 'usr_2'],
            createdAt: DateTime.now(),
          ),
        ];
  }

  @override
  Future<ExpenseEntity> createExpense({
    required String tripId,
    double? amount,
    String? description,
    String? category,
    String? receiptImageUrl,
    List<String>? splitMemberIds,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return ExpenseEntity(
      id: 'exp_2',
      groupId: tripId,
      paidByUserId: 'usr_1',
      paidByUsername: 'rashi',
      paidByFullName: 'Rashi',
      amount: amount ?? 500.0,
      description: description ?? 'Dinner',
      category: category ?? 'Food',
      status: 'approved',
      splitMemberIds: splitMemberIds ?? const ['usr_1'],
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ExpenseLedgerEntity> getGroupLedger(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return ledgerToReturn ??
        const ExpenseLedgerEntity(
          grandTotal: 60000.0,
          myPaidAmount: 20000.0,
          myShareAmount: 15000.0,
          myBalance: 5000.0,
        );
  }

  @override
  Future<List<ExpenseSettlementEntity>> getSettlements(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return settlementsToReturn ??
        const [
          ExpenseSettlementEntity(
            id: 'set_1',
            fromUserId: 'usr_2',
            fromUserName: 'Anshl',
            toUserId: 'usr_1',
            toUserName: 'Rashi',
            amount: 5000.0,
            isCompleted: false,
          ),
        ];
  }
}

void main() {
  group('ExpenseModel JSON Parsing', () {
    test('fromJson correctly parses backend expense payload', () {
      final json = {
        'id': 'exp_100',
        'groupId': 'trip_10',
        'paidByUserId': 'usr_5',
        'amount': 8400.0,
        'description': 'Seafood Dinner',
        'category': 'Food',
        'status': 'approved',
        'payer': {'id': 'usr_5', 'username': 'alex', 'fullName': 'Alex Smith'},
        'splits': [
          {'userId': 'usr_5'},
          {'userId': 'usr_6'}
        ]
      };

      final model = ExpenseModel.fromJson(json);

      expect(model.id, 'exp_100');
      expect(model.amount, 8400.0);
      expect(model.description, 'Seafood Dinner');
      expect(model.paidByFullName, 'Alex Smith');
      expect(model.splitMemberIds.length, 2);
    });
  });

  group('ExpenseBloc Unit Tests', () {
    late FakeExpenseRepository fakeRepository;
    late ExpenseBloc expenseBloc;

    setUp(() {
      fakeRepository = FakeExpenseRepository();
      expenseBloc = ExpenseBloc(
        getGroupExpensesUseCase: GetGroupExpensesUseCase(fakeRepository),
        createExpenseUseCase: CreateExpenseUseCase(fakeRepository),
        getGroupLedgerUseCase: GetGroupLedgerUseCase(fakeRepository),
        getSettlementsUseCase: GetSettlementsUseCase(fakeRepository),
      );
    });

    tearDown(() {
      expenseBloc.close();
    });

    test('initial state is ExpenseInitialState', () {
      expect(expenseBloc.state, isA<ExpenseInitialState>());
    });

    test('ExpensesFetchRequested success emits ExpensesLoadedState', () async {
      expenseBloc.add(const ExpensesFetchRequested(tripId: 'trip_10'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(expenseBloc.state, isA<ExpensesLoadedState>());
      final loaded = expenseBloc.state as ExpensesLoadedState;
      expect(loaded.expenses.length, 1);
      expect(loaded.expenses.first.amount, 32000.0);
    });

    test('ExpenseCreateRequested creates expense and updates list', () async {
      expenseBloc.add(const ExpenseCreateRequested(
        tripId: 'trip_10',
        amount: 500.0,
        description: 'Snacks',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(expenseBloc.state, isA<ExpensesLoadedState>());
      final loaded = expenseBloc.state as ExpensesLoadedState;
      expect(loaded.successMessage, contains('recorded successfully'));
    });
  });
}
