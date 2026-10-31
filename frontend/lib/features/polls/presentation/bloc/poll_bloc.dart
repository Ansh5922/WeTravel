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
  final UpdatePollUseCase? updatePollUseCase;
  final DeletePollUseCase? deletePollUseCase;

  PollBloc({
    required this.getPollsUseCase,
    required this.createPollUseCase,
    required this.castVoteUseCase,
    required this.closePollUseCase,
    this.updatePollUseCase,
    this.deletePollUseCase,
  }) : super(PollInitialState()) {
    on<PollsFetchRequested>(_onPollsFetchRequested);
    on<PollCreateRequested>(_onPollCreateRequested);
    on<PollUpdateRequested>(_onPollUpdateRequested);
    on<PollDeleteRequested>(_onPollDeleteRequested);
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
    debugPrint('[POLL_BLOC] ➕ Event: PollCreateRequested (question: "${event.question}", anon: ${event.isAnonymous})');

    try {
      await createPollUseCase(
        tripId: event.tripId,
        question: event.question,
        options: event.options,
        isAnonymous: event.isAnonymous,
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

  Future<void> _onPollUpdateRequested(
    PollUpdateRequested event,
    Emitter<PollState> emit,
  ) async {
    debugPrint('[POLL_BLOC] ✏️ Event: PollUpdateRequested (pollId: ${event.pollId})');

    try {
      if (updatePollUseCase != null) {
        await updatePollUseCase!(
          tripId: event.tripId,
          pollId: event.pollId,
          question: event.question,
          options: event.options,
        );
      }
      debugPrint('[POLL_BLOC] ✅ Poll updated successfully!');

      final polls = await getPollsUseCase(event.tripId);
      emit(PollsLoadedState(
        polls: polls,
        successMessage: 'Poll updated successfully.',
      ));
    } on ServerException catch (e) {
      debugPrint('[POLL_BLOC] ❌ Update Error: ${e.message}');
      emit(PollErrorState(message: e.message));
    } catch (e) {
      debugPrint('[POLL_BLOC] 💥 Unexpected Update Error: $e');
      emit(PollErrorState(message: 'Failed to update poll: ${e.toString()}'));
    }
  }

  Future<void> _onPollDeleteRequested(
    PollDeleteRequested event,
    Emitter<PollState> emit,
  ) async {
    debugPrint('[POLL_BLOC] 🗑️ Event: PollDeleteRequested (pollId: ${event.pollId})');

    try {
      if (deletePollUseCase != null) {
        await deletePollUseCase!(
          tripId: event.tripId,
          pollId: event.pollId,
        );
      }
      debugPrint('[POLL_BLOC] ✅ Poll deleted successfully!');

      final polls = await getPollsUseCase(event.tripId);
      emit(PollsLoadedState(
        polls: polls,
        successMessage: 'Poll deleted.',
      ));
    } on ServerException catch (e) {
      debugPrint('[POLL_BLOC] ❌ Delete Error: ${e.message}');
      emit(PollErrorState(message: e.message));
    } catch (e) {
      debugPrint('[POLL_BLOC] 💥 Unexpected Delete Error: $e');
      emit(PollErrorState(message: 'Failed to delete poll: ${e.toString()}'));
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
      debugPrint('[POLL_BLOC] 🔒 Poll closed successfully!');

      final polls = await getPollsUseCase(event.tripId);
      emit(PollsLoadedState(
        polls: polls,
        successMessage: 'Poll closed. Preferences updated!',
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
