import '../entities/memory_entity.dart';

abstract class MemoryRepository {
  Future<List<MemoryEntity>> getMemoriesTimeline(String tripId);
  Future<List<MemoryEntity>> getHighlights(String tripId);
  Future<List<MemoryEntity>> uploadMemories({
    required String tripId,
    required List<Map<String, dynamic>> photos,
  });
  Future<MemoryEntity> toggleHighlight(String tripId, String memoryId);
  Future<void> deleteMemory(String tripId, String memoryId);
}
