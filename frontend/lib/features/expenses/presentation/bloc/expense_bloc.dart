import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/get_group_expenses_usecase.dart';
import '../../domain/usecases/get_group_ledger_usecase.dart';
import '../../domain/usecases/get_settlements_usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetGroupExpensesUseCase getGroupExpensesUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final GetGroupLedgerUseCase getGroupLedgerUseCase;
  final GetSettlementsUseCase getSettlementsUseCase;

  ExpenseBloc({
    required this.getGroupExpensesUseCase,
    required this.createExpenseUseCase,
    required this.getGroupLedgerUseCase,
    required this.getSettlementsUseCase,
  }) : super(ExpenseInitialState()) {
    on<ExpensesFetchRequested>(_onExpensesFetchRequested);
    on<ExpenseCreateRequested>(_onExpenseCreateRequested);
    on<GroupLedgerRequested>(_onGroupLedgerRequested);
    on<SettlementsRequested>(_onSettlementsRequested);
  }

  Future<void> _onExpensesFetchRequested(
    ExpensesFetchRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    debugPrint('[EXPENSE_BLOC] 💸 Event: ExpensesFetchRequested (tripId: ${event.tripId}, filter: ${event.statusFilter})');
    emit(ExpenseLoadingState());

    try {
      final expenses = await getGroupExpensesUseCase(event.tripId, status: event.statusFilter);
      debugPrint('[EXPENSE_BLOC] ✅ Fetch Success: Loaded ${expenses.length} expense item(s)');
      emit(ExpensesLoadedState(expenses: expenses));
    } on ServerException catch (e) {
      debugPrint('[EXPENSE_BLOC] ❌ Fetch Error: ${e.message}');
      emit(ExpenseErrorState(message: e.message));
    } catch (e) {
      debugPrint('[EXPENSE_BLOC] 💥 Unexpected Fetch Error: $e');
      emit(ExpenseErrorState(message: 'Failed to fetch trip expenses: ${e.toString()}'));
    }
  }

  Future<void> _onExpenseCreateRequested(
    ExpenseCreateRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    debugPrint('[EXPENSE_BLOC] ➕ Event: ExpenseCreateRequested -> Amount: ${event.amount}, Category: ${event.category}, Desc: ${event.description}');
    emit(ExpenseLoadingState());

    try {
      final created = await createExpenseUseCase(
        tripId: event.tripId,
        amount: event.amount,
        description: event.description,
        category: event.category,
        receiptImageUrl: event.receiptImageUrl,
        splitMemberIds: event.splitMemberIds,
      );

      debugPrint('[EXPENSE_BLOC] ✅ Expense Created! ID: ${created.id}, Amount: ₹${created.amount}');
      final expenses = await getGroupExpensesUseCase(event.tripId);

      emit(ExpensesLoadedState(
        expenses: expenses,
        successMessage: 'Expense of ₹${created.amount} recorded successfully!',
      ));
    } on ServerException catch (e) {
      debugPrint('[EXPENSE_BLOC] ❌ Create Error: ${e.message}');
      emit(ExpenseErrorState(message: e.message));
    } catch (e) {
      debugPrint('[EXPENSE_BLOC] 💥 Unexpected Create Error: $e');
      emit(ExpenseErrorState(message: 'Failed to create expense: ${e.toString()}'));
    }
  }

  Future<void> _onGroupLedgerRequested(
    GroupLedgerRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    debugPrint('[EXPENSE_BLOC] 📊 Event: GroupLedgerRequested (tripId: ${event.tripId})');

    try {
      final ledger = await getGroupLedgerUseCase(event.tripId);
      debugPrint('[EXPENSE_BLOC] ✅ Ledger Fetched: GrandTotal: ₹${ledger.grandTotal}, Balance: ₹${ledger.myBalance}');

      if (state is ExpensesLoadedState) {
        final current = state as ExpensesLoadedState;
        emit(current.copyWith(ledger: ledger));
      } else {
        emit(ExpensesLoadedState(expenses: const [], ledger: ledger));
      }
    } on ServerException catch (e) {
      debugPrint('[EXPENSE_BLOC] ❌ Ledger Error: ${e.message}');
      emit(ExpenseErrorState(message: e.message));
    } catch (e) {
      debugPrint('[EXPENSE_BLOC] 💥 Unexpected Ledger Error: $e');
      emit(ExpenseErrorState(message: 'Failed to fetch ledger: ${e.toString()}'));
    }
  }

  Future<void> _onSettlementsRequested(
    SettlementsRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    debugPrint('[EXPENSE_BLOC] 🤝 Event: SettlementsRequested (tripId: ${event.tripId})');

    try {
      final settlements = await getSettlementsUseCase(event.tripId);
      debugPrint('[EXPENSE_BLOC] ✅ Settlements Fetched: ${settlements.length} transaction(s)');

      if (state is ExpensesLoadedState) {
        final current = state as ExpensesLoadedState;
        emit(current.copyWith(settlements: settlements));
      } else {
        emit(ExpensesLoadedState(expenses: const [], settlements: settlements));
      }
    } on ServerException catch (e) {
      debugPrint('[EXPENSE_BLOC] ❌ Settlement Error: ${e.message}');
      emit(ExpenseErrorState(message: e.message));
    } catch (e) {
      debugPrint('[EXPENSE_BLOC] 💥 Unexpected Settlement Error: $e');
      emit(ExpenseErrorState(message: 'Failed to fetch settlements: ${e.toString()}'));
    }
  }
}
