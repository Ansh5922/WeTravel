import '../entities/memory_entity.dart';
import '../repositories/memory_repository.dart';

class GetMemoriesTimelineUseCase {
  final MemoryRepository repository;
  GetMemoriesTimelineUseCase(this.repository);

  Future<List<MemoryEntity>> call(String tripId) async {
    return await repository.getMemoriesTimeline(tripId);
  }
}

class GetMemoryHighlightsUseCase {
  final MemoryRepository repository;
  GetMemoryHighlightsUseCase(this.repository);

  Future<List<MemoryEntity>> call(String tripId) async {
    return await repository.getHighlights(tripId);
  }
}

class UploadMemoriesUseCase {
  final MemoryRepository repository;
  UploadMemoriesUseCase(this.repository);

  Future<List<MemoryEntity>> call({
    required String tripId,
    required List<Map<String, dynamic>> photos,
  }) async {
    return await repository.uploadMemories(tripId: tripId, photos: photos);
  }
}

class ToggleMemoryHighlightUseCase {
  final MemoryRepository repository;
  ToggleMemoryHighlightUseCase(this.repository);

  Future<MemoryEntity> call(String tripId, String memoryId) async {
    return await repository.toggleHighlight(tripId, memoryId);
  }
}

class DeleteMemoryUseCase {
  final MemoryRepository repository;
  DeleteMemoryUseCase(this.repository);

  Future<void> call(String tripId, String memoryId) async {
    await repository.deleteMemory(tripId, memoryId);
  }
}
