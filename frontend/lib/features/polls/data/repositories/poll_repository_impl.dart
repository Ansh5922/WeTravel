import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/poll_repository.dart';
import '../datasources/poll_remote_data_source.dart';

class PollRepositoryImpl implements PollRepository {
  final PollRemoteDataSource remoteDataSource;

  PollRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PollEntity>> getPolls(String tripId) {
    return remoteDataSource.getPolls(tripId);
  }

  @override
  Future<PollEntity> createPoll({
    required String tripId,
    required String question,
    required List<String> options,
    bool isAnonymous = false,
  }) {
    return remoteDataSource.createPoll(
      tripId: tripId,
      question: question,
      options: options,
      isAnonymous: isAnonymous,
    );
  }

  @override
  Future<PollEntity> updatePoll({
    required String tripId,
    required String pollId,
    String? question,
    List<String>? options,
  }) {
    return remoteDataSource.updatePoll(
      tripId: tripId,
      pollId: pollId,
      question: question,
      options: options,
    );
  }

  @override
  Future<void> deletePoll({
    required String tripId,
    required String pollId,
  }) {
    return remoteDataSource.deletePoll(
      tripId: tripId,
      pollId: pollId,
    );
  }

  @override
  Future<PollEntity> castVote({
    required String tripId,
    required String pollId,
    required String optionId,
  }) {
    return remoteDataSource.castVote(
      tripId: tripId,
      pollId: pollId,
      optionId: optionId,
    );
  }

  @override
  Future<PollEntity> closePoll({
    required String tripId,
    required String pollId,
  }) {
    return remoteDataSource.closePoll(
      tripId: tripId,
      pollId: pollId,
    );
  }
}
