import 'package:equatable/equatable.dart';

abstract class PollEvent extends Equatable {
  const PollEvent();

  @override
  List<Object?> get props => [];
}

class PollsFetchRequested extends PollEvent {
  final String tripId;
  const PollsFetchRequested({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class PollCreateRequested extends PollEvent {
  final String tripId;
  final String question;
  final List<String> options;

  const PollCreateRequested({
    required this.tripId,
    required this.question,
    required this.options,
  });

  @override
  List<Object?> get props => [tripId, question, options];
}

class PollVoteRequested extends PollEvent {
  final String tripId;
  final String pollId;
  final String optionId;

  const PollVoteRequested({
    required this.tripId,
    required this.pollId,
    required this.optionId,
  });

  @override
  List<Object?> get props => [tripId, pollId, optionId];
}

class PollCloseRequested extends PollEvent {
  final String tripId;
  final String pollId;

  const PollCloseRequested({
    required this.tripId,
    required this.pollId,
  });

  @override
  List<Object?> get props => [tripId, pollId];
}
