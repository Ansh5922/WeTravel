import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/poll_usecases.dart';
import 'poll_event.dart';
import 'poll_state.dart';

class PollBloc extends Bloc<PollEvent, PollState> {
  final GetPollsUseCase getPollsUseCase;
  final CreatePollUseCase createPollUseCase;
  final CastVoteUseCase castVoteUseCase;
  final ClosePollUseCase closePollUseCase;

  PollBloc({
    required this.getPollsUseCase,
    required this.createPollUseCase,
    required this.castVoteUseCase,
    required this.closePollUseCase,
  }) : super(PollInitialState()) {
    on<PollsFetchRequested>(_onPollsFetchRequested);
    on<PollCreateRequested>(_onPollCreateRequested);
    on<PollVoteRequested>(_onPollVoteRequested);
    on<PollCloseRequested>(_onPollCloseRequested);
  }

  Future<void> _onPollsFetchRequested(
    PollsFetchRequested event,
    Emitter<PollState> emit,
  ) async {
    debugPrint('[POLL_BLOC] 📊 Event: PollsFetchRequested (tripId: ${event.tripId})');
    emit(PollLoadingState());

    try {
      final polls = await getPollsUseCase(event.tripId);
      debugPrint('[POLL_BLOC] ✅ Loaded ${polls.length} poll(s)');
      emit(PollsLoadedState(polls: polls));
    } on ServerException catch (e) {
      debugPrint('[POLL_BLOC] ❌ Fetch Error: ${e.message}');
      emit(PollErrorState(message: e.message));
    } catch (e) {
      debugPrint('[POLL_BLOC] 💥 Unexpected Fetch Error: $e');
      emit(PollErrorState(message: 'Failed to fetch polls: ${e.toString()}'));
    }
  }

  Future<void> _onPollCreateRequested(
    PollCreateRequested event,
    Emitter<PollState> emit,
  ) async {
    debugPrint('[POLL_BLOC] ➕ Event: PollCreateRequested (question: "${event.question}")');

    try {
      await createPollUseCase(
        tripId: event.tripId,
        question: event.question,
        options: event.options,
      );
      debugPrint('[POLL_BLOC] 🎉 Poll created successfully!');

      final polls = await getPollsUseCase(event.tripId);
      emit(PollsLoadedState(
        polls: polls,
        successMessage: 'Poll created.',
      ));
    } on ServerException catch (e) {
      debugPrint('[POLL_BLOC] ❌ Create Error: ${e.message}');
      emit(PollErrorState(message: e.message));
    } catch (e) {
      debugPrint('[POLL_BLOC] 💥 Unexpected Create Error: $e');
      emit(PollErrorState(message: 'Failed to create poll: ${e.toString()}'));
    }
  }

  Future<void> _onPollVoteRequested(
    PollVoteRequested event,
    Emitter<PollState> emit,
  ) async {
    debugPrint('[POLL_BLOC] 🗳️ Event: PollVoteRequested (pollId: ${event.pollId}, optionId: ${event.optionId})');

    try {
      await castVoteUseCase(
        tripId: event.tripId,
        pollId: event.pollId,
        optionId: event.optionId,
      );
      debugPrint('[POLL_BLOC] ✅ Vote recorded!');

      final polls = await getPollsUseCase(event.tripId);
      emit(PollsLoadedState(
        polls: polls,
        successMessage: 'Vote recorded.',
      ));
    } on ServerException catch (e) {
      debugPrint('[POLL_BLOC] ❌ Vote Error: ${e.message}');
      emit(PollErrorState(message: e.message));
    } catch (e) {
      debugPrint('[POLL_BLOC] 💥 Unexpected Vote Error: $e');
      emit(PollErrorState(message: 'Failed to record vote: ${e.toString()}'));
    }
  }

  Future<void> _onPollCloseRequested(
    PollCloseRequested event,
    Emitter<PollState> emit,
  ) async {
    debugPrint('[POLL_BLOC] 🔒 Event: PollCloseRequested (pollId: ${event.pollId})');

    try {
      await closePollUseCase(
        tripId: event.tripId,
        pollId: event.pollId,
      );
      debugPrint('[POLL_BLOC] ✅ Poll closed and results sent to AI!');

      final polls = await getPollsUseCase(event.tripId);
      emit(PollsLoadedState(
        polls: polls,
        successMessage: 'Poll closed. AI consensus updated.',
      ));
    } on ServerException catch (e) {
      debugPrint('[POLL_BLOC] ❌ Close Error: ${e.message}');
      emit(PollErrorState(message: e.message));
    } catch (e) {
      debugPrint('[POLL_BLOC] 💥 Unexpected Close Error: $e');
      emit(PollErrorState(message: 'Failed to close poll: ${e.toString()}'));
    }
  }
}
