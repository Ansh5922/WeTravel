import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/poll_repository.dart';
import '../datasources/poll_remote_data_source.dart';

class PollRepositoryImpl implements PollRepository {
  final PollRemoteDataSource remoteDataSource;

  PollRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PollEntity>> getPolls(String tripId) async {
    try {
      return await remoteDataSource.getPolls(tripId);
    } on ServerException catch (e) {
      debugPrint('[POLL_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[POLL_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch polls: ${e.toString()}');
    }
  }

  @override
  Future<PollEntity> createPoll({
    required String tripId,
    required String question,
    required List<String> options,
  }) async {
    try {
      return await remoteDataSource.createPoll(
        tripId: tripId,
        question: question,
        options: options,
      );
    } on ServerException catch (e) {
      debugPrint('[POLL_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[POLL_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to create poll: ${e.toString()}');
    }
  }

  @override
  Future<PollEntity> castVote({
    required String tripId,
    required String pollId,
    required String optionId,
  }) async {
    try {
      return await remoteDataSource.castVote(
        tripId: tripId,
        pollId: pollId,
        optionId: optionId,
      );
    } on ServerException catch (e) {
      debugPrint('[POLL_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[POLL_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to vote on poll: ${e.toString()}');
    }
  }

  @override
  Future<PollEntity> closePoll({
    required String tripId,
    required String pollId,
  }) async {
    try {
      return await remoteDataSource.closePoll(tripId: tripId, pollId: pollId);
    } on ServerException catch (e) {
      debugPrint('[POLL_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[POLL_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to close poll: ${e.toString()}');
    }
  }
}
