import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/memory_usecases.dart';
import 'memory_event.dart';
import 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final GetMemoriesTimelineUseCase getMemoriesTimelineUseCase;
  final GetMemoryHighlightsUseCase getMemoryHighlightsUseCase;
  final UploadMemoriesUseCase uploadMemoriesUseCase;
  final ToggleMemoryHighlightUseCase toggleMemoryHighlightUseCase;
  final DeleteMemoryUseCase deleteMemoryUseCase;

  MemoryBloc({
    required this.getMemoriesTimelineUseCase,
    required this.getMemoryHighlightsUseCase,
    required this.uploadMemoriesUseCase,
    required this.toggleMemoryHighlightUseCase,
    required this.deleteMemoryUseCase,
  }) : super(MemoryInitialState()) {
    on<MemoriesFetchRequested>(_onMemoriesFetchRequested);
    on<MemoryHighlightsFetchRequested>(_onMemoryHighlightsFetchRequested);
    on<MemoryUploadRequested>(_onMemoryUploadRequested);
    on<MemoryToggleHighlightRequested>(_onMemoryToggleHighlightRequested);
    on<MemoryDeleteRequested>(_onMemoryDeleteRequested);
  }

  Future<void> _onMemoriesFetchRequested(
    MemoriesFetchRequested event,
    Emitter<MemoryState> emit,
  ) async {
    debugPrint('[MEMORY_BLOC] 📸 Event: MemoriesFetchRequested (tripId: ${event.tripId})');
    emit(MemoryLoadingState());

    try {
      final memories = await getMemoriesTimelineUseCase(event.tripId);
      final highlights = await getMemoryHighlightsUseCase(event.tripId);

      debugPrint('[MEMORY_BLOC] ✅ Loaded ${memories.length} memory photo(s) and ${highlights.length} highlight(s)');
      emit(MemoriesLoadedState(memories: memories, highlights: highlights));
    } on ServerException catch (e) {
      debugPrint('[MEMORY_BLOC] ❌ Fetch Error: ${e.message}');
      emit(MemoryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[MEMORY_BLOC] 💥 Unexpected Fetch Error: $e');
      emit(MemoryErrorState(message: 'Failed to fetch memories: ${e.toString()}'));
    }
  }

  Future<void> _onMemoryHighlightsFetchRequested(
    MemoryHighlightsFetchRequested event,
    Emitter<MemoryState> emit,
  ) async {
    debugPrint('[MEMORY_BLOC] ⭐ Event: MemoryHighlightsFetchRequested (tripId: ${event.tripId})');

    try {
      final highlights = await getMemoryHighlightsUseCase(event.tripId);
      debugPrint('[MEMORY_BLOC] ✅ Loaded ${highlights.length} highlight(s)');

      if (state is MemoriesLoadedState) {
        emit((state as MemoriesLoadedState).copyWith(highlights: highlights));
      }
    } on ServerException catch (e) {
      debugPrint('[MEMORY_BLOC] ❌ Highlights Error: ${e.message}');
    } catch (e) {
      debugPrint('[MEMORY_BLOC] 💥 Unexpected Highlights Error: $e');
    }
  }

  Future<void> _onMemoryUploadRequested(
    MemoryUploadRequested event,
    Emitter<MemoryState> emit,
  ) async {
    debugPrint('[MEMORY_BLOC] 📤 Event: MemoryUploadRequested (tripId: ${event.tripId}, photos: ${event.photos.length})');

    try {
      await uploadMemoriesUseCase(tripId: event.tripId, photos: event.photos);
      debugPrint('[MEMORY_BLOC] 🎉 Photo(s) uploaded successfully!');

      final memories = await getMemoriesTimelineUseCase(event.tripId);
      final highlights = await getMemoryHighlightsUseCase(event.tripId);

      emit(MemoriesLoadedState(
        memories: memories,
        highlights: highlights,
        successMessage: 'Photo(s) added to trip memory vault.',
      ));
    } on ServerException catch (e) {
      debugPrint('[MEMORY_BLOC] ❌ Upload Error: ${e.message}');
      emit(MemoryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[MEMORY_BLOC] 💥 Unexpected Upload Error: $e');
      emit(MemoryErrorState(message: 'Failed to upload memories: ${e.toString()}'));
    }
  }

  Future<void> _onMemoryToggleHighlightRequested(
    MemoryToggleHighlightRequested event,
    Emitter<MemoryState> emit,
  ) async {
    debugPrint('[MEMORY_BLOC] ✏️ Event: MemoryToggleHighlightRequested (memoryId: ${event.memoryId})');

    try {
      await toggleMemoryHighlightUseCase(event.tripId, event.memoryId);
      debugPrint('[MEMORY_BLOC] ✅ Highlight toggled!');

      final memories = await getMemoriesTimelineUseCase(event.tripId);
      final highlights = await getMemoryHighlightsUseCase(event.tripId);

      emit(MemoriesLoadedState(memories: memories, highlights: highlights));
    } on ServerException catch (e) {
      debugPrint('[MEMORY_BLOC] ❌ Toggle Highlight Error: ${e.message}');
      emit(MemoryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[MEMORY_BLOC] 💥 Unexpected Toggle Highlight Error: $e');
      emit(MemoryErrorState(message: 'Failed to toggle highlight: ${e.toString()}'));
    }
  }

  Future<void> _onMemoryDeleteRequested(
    MemoryDeleteRequested event,
    Emitter<MemoryState> emit,
  ) async {
    debugPrint('[MEMORY_BLOC] 🗑️ Event: MemoryDeleteRequested (memoryId: ${event.memoryId})');

    try {
      await deleteMemoryUseCase(event.tripId, event.memoryId);
      debugPrint('[MEMORY_BLOC] ✅ Photo deleted successfully.');

      final memories = await getMemoriesTimelineUseCase(event.tripId);
      final highlights = await getMemoryHighlightsUseCase(event.tripId);

      emit(MemoriesLoadedState(
        memories: memories,
        highlights: highlights,
        successMessage: 'Photo deleted.',
      ));
    } on ServerException catch (e) {
      debugPrint('[MEMORY_BLOC] ❌ Delete Error: ${e.message}');
      emit(MemoryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[MEMORY_BLOC] 💥 Unexpected Delete Error: $e');
      emit(MemoryErrorState(message: 'Failed to delete photo: ${e.toString()}'));
    }
  }
}
