import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/memory_entity.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/memory_remote_data_source.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryRemoteDataSource remoteDataSource;

  MemoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MemoryEntity>> getMemoriesTimeline(String tripId) async {
    try {
      return await remoteDataSource.getMemoriesTimeline(tripId);
    } on ServerException catch (e) {
      debugPrint('[MEMORY_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[MEMORY_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch memory timeline: ${e.toString()}');
    }
  }

  @override
  Future<List<MemoryEntity>> getHighlights(String tripId) async {
    try {
      return await remoteDataSource.getHighlights(tripId);
    } on ServerException catch (e) {
      debugPrint('[MEMORY_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[MEMORY_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch highlights: ${e.toString()}');
    }
  }

  @override
  Future<List<MemoryEntity>> uploadMemories({
    required String tripId,
    required List<Map<String, dynamic>> photos,
  }) async {
    try {
      return await remoteDataSource.uploadMemories(tripId: tripId, photos: photos);
    } on ServerException catch (e) {
      debugPrint('[MEMORY_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[MEMORY_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to upload memories: ${e.toString()}');
    }
  }

  @override
  Future<MemoryEntity> toggleHighlight(String tripId, String memoryId) async {
    try {
      return await remoteDataSource.toggleHighlight(tripId, memoryId);
    } on ServerException catch (e) {
      debugPrint('[MEMORY_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[MEMORY_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to toggle highlight: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMemory(String tripId, String memoryId) async {
    try {
      await remoteDataSource.deleteMemory(tripId, memoryId);
    } on ServerException catch (e) {
      debugPrint('[MEMORY_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[MEMORY_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to delete memory: ${e.toString()}');
    }
  }
}
