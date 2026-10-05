import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../models/poll_model.dart';

abstract class PollRemoteDataSource {
  Future<List<PollModel>> getPolls(String tripId);
  Future<PollModel> createPoll({
    required String tripId,
    required String question,
    required List<String> options,
  });
  Future<PollModel> castVote({
    required String tripId,
    required String pollId,
    required String optionId,
  });
  Future<PollModel> closePoll({
    required String tripId,
    required String pollId,
  });
}

class PollRemoteDataSourceImpl implements PollRemoteDataSource {
  final Dio dio;

  PollRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PollModel>> getPolls(String tripId) async {
    final path = '/api/trips/$tripId/chat/polls';
    debugPrint('[POLL_REMOTE_DS] 📊 GET $path');

    try {
      final response = await dio.get(path);
      debugPrint('[POLL_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['polls'] ?? [];
        return list.map((item) => PollModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch polls',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[POLL_REMOTE_DS] ❌ DioError GET polls: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error fetching polls',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<PollModel> createPoll({
    required String tripId,
    required String question,
    required List<String> options,
  }) async {
    final path = '/api/trips/$tripId/chat/polls';
    debugPrint('[POLL_REMOTE_DS] ➕ POST $path -> question: "$question" (${options.length} options)');

    try {
      final response = await dio.post(
        path,
        data: {
          'question': question,
          'options': options,
        },
      );
      debugPrint('[POLL_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['status'] == 'success') {
        return PollModel.fromJson(response.data['data']['poll']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to create poll',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[POLL_REMOTE_DS] ❌ DioError POST poll: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error creating poll',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<PollModel> castVote({
    required String tripId,
    required String pollId,
    required String optionId,
  }) async {
    final path = '/api/trips/$tripId/chat/polls/$pollId/vote';
    debugPrint('[POLL_REMOTE_DS] 🗳️ POST $path -> optionId: $optionId');

    try {
      final response = await dio.post(
        path,
        data: {'optionId': optionId},
      );
      debugPrint('[POLL_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data']['vote'];
        final pollJson = data['poll'] ?? data;
        return PollModel.fromJson(pollJson);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to record vote',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[POLL_REMOTE_DS] ❌ DioError POST vote: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error voting on poll',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<PollModel> closePoll({
    required String tripId,
    required String pollId,
  }) async {
    final path = '/api/trips/$tripId/chat/polls/$pollId/close';
    debugPrint('[POLL_REMOTE_DS] 🔒 PATCH $path');

    try {
      final response = await dio.patch(path);
      debugPrint('[POLL_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return PollModel.fromJson(response.data['data']['poll']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to close poll',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[POLL_REMOTE_DS] ❌ DioError PATCH close poll: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error closing poll',
        e.response?.statusCode,
      );
    }
  }
}
