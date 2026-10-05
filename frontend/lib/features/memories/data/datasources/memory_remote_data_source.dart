import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../models/memory_model.dart';

abstract class MemoryRemoteDataSource {
  Future<List<MemoryModel>> getMemoriesTimeline(String tripId);
  Future<List<MemoryModel>> getHighlights(String tripId);
  Future<List<MemoryModel>> uploadMemories({
    required String tripId,
    required List<Map<String, dynamic>> photos,
  });
  Future<MemoryModel> toggleHighlight(String tripId, String memoryId);
  Future<void> deleteMemory(String tripId, String memoryId);
}

class MemoryRemoteDataSourceImpl implements MemoryRemoteDataSource {
  final Dio dio;

  MemoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<MemoryModel>> getMemoriesTimeline(String tripId) async {
    final path = '/api/trips/$tripId/memories';
    debugPrint('[MEMORY_REMOTE_DS] 📸 GET $path');

    try {
      final response = await dio.get(path);
      debugPrint('[MEMORY_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['memories'] ?? [];
        return list.map((item) => MemoryModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch memory timeline',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[MEMORY_REMOTE_DS] ❌ DioError GET memories: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error fetching memories',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<MemoryModel>> getHighlights(String tripId) async {
    final path = '/api/trips/$tripId/memories/highlights';
    debugPrint('[MEMORY_REMOTE_DS] ⭐ GET $path');

    try {
      final response = await dio.get(path);
      debugPrint('[MEMORY_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['highlights'] ?? [];
        return list.map((item) => MemoryModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch highlights',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[MEMORY_REMOTE_DS] ❌ DioError GET highlights: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error fetching highlights',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<MemoryModel>> uploadMemories({
    required String tripId,
    required List<Map<String, dynamic>> photos,
  }) async {
    final path = '/api/trips/$tripId/memories';
    debugPrint('[MEMORY_REMOTE_DS] 📤 POST $path -> ${photos.length} photo(s)');

    try {
      final response = await dio.post(
        path,
        data: {'photos': photos},
      );
      debugPrint('[MEMORY_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['status'] == 'success') {
        final List list = response.data['data']['memories'] ?? [];
        return list.map((item) => MemoryModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to upload memories',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[MEMORY_REMOTE_DS] ❌ DioError POST memories: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error uploading memories',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<MemoryModel> toggleHighlight(String tripId, String memoryId) async {
    final path = '/api/trips/$tripId/memories/$memoryId/highlight';
    debugPrint('[MEMORY_REMOTE_DS] ✏️ PATCH $path');

    try {
      final response = await dio.patch(path);
      debugPrint('[MEMORY_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return MemoryModel.fromJson(response.data['data']['memory']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to toggle highlight',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[MEMORY_REMOTE_DS] ❌ DioError PATCH highlight: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error toggling highlight',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteMemory(String tripId, String memoryId) async {
    final path = '/api/trips/$tripId/memories/$memoryId';
    debugPrint('[MEMORY_REMOTE_DS] 🗑️ DELETE $path');

    try {
      final response = await dio.delete(path);
      debugPrint('[MEMORY_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode != 200 || response.data['status'] != 'success') {
        throw ServerException(
          response.data['message'] ?? 'Failed to delete memory',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[MEMORY_REMOTE_DS] ❌ DioError DELETE memory: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error deleting memory',
        e.response?.statusCode,
      );
    }
  }
}
