import '../entities/poll_entity.dart';

abstract class PollRepository {
  Future<List<PollEntity>> getPolls(String tripId);
  Future<PollEntity> createPoll({
    required String tripId,
    required String question,
    required List<String> options,
  });
  Future<PollEntity> castVote({
    required String tripId,
    required String pollId,
    required String optionId,
  });
  Future<PollEntity> closePoll({
    required String tripId,
    required String pollId,
  });
}
