import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitialState extends ExpenseState {}

class ExpenseLoadingState extends ExpenseState {}

class ExpensesLoadedState extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final ExpenseLedgerEntity? ledger;
  final List<ExpenseSettlementEntity> settlements;
  final String? successMessage;

  const ExpensesLoadedState({
    required this.expenses,
    this.ledger,
    this.settlements = const [],
    this.successMessage,
  });

  ExpensesLoadedState copyWith({
    List<ExpenseEntity>? expenses,
    ExpenseLedgerEntity? ledger,
    List<ExpenseSettlementEntity>? settlements,
    String? successMessage,
  }) {
    return ExpensesLoadedState(
      expenses: expenses ?? this.expenses,
      ledger: ledger ?? this.ledger,
      settlements: settlements ?? this.settlements,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [expenses, ledger, settlements, successMessage];
}

class ExpenseErrorState extends ExpenseState {
  final String message;

  const ExpenseErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
