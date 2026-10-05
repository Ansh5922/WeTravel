import 'package:equatable/equatable.dart';
import '../../domain/entities/poll_entity.dart';

abstract class PollState extends Equatable {
  const PollState();

  @override
  List<Object?> get props => [];
}

class PollInitialState extends PollState {}

class PollLoadingState extends PollState {}

class PollsLoadedState extends PollState {
  final List<PollEntity> polls;
  final String? successMessage;

  const PollsLoadedState({
    required this.polls,
    this.successMessage,
  });

  PollsLoadedState copyWith({
    List<PollEntity>? polls,
    String? successMessage,
  }) {
    return PollsLoadedState(
      polls: polls ?? this.polls,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [polls, successMessage];
}

class PollErrorState extends PollState {
  final String message;
  const PollErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
