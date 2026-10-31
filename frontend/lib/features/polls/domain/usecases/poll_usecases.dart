import '../entities/poll_entity.dart';
import '../repositories/poll_repository.dart';

class GetPollsUseCase {
  final PollRepository repository;
  GetPollsUseCase(this.repository);

  Future<List<PollEntity>> call(String tripId) async {
    return await repository.getPolls(tripId);
  }
}

class CreatePollUseCase {
  final PollRepository repository;
  CreatePollUseCase(this.repository);

  Future<PollEntity> call({
    required String tripId,
    required String question,
    required List<String> options,
    bool isAnonymous = false,
  }) async {
    return await repository.createPoll(
      tripId: tripId,
      question: question,
      options: options,
      isAnonymous: isAnonymous,
    );
  }
}

class UpdatePollUseCase {
  final PollRepository repository;
  UpdatePollUseCase(this.repository);

  Future<PollEntity> call({
    required String tripId,
    required String pollId,
    String? question,
    List<String>? options,
  }) async {
    return await repository.updatePoll(
      tripId: tripId,
      pollId: pollId,
      question: question,
      options: options,
    );
  }
}

class DeletePollUseCase {
  final PollRepository repository;
  DeletePollUseCase(this.repository);

  Future<void> call({
    required String tripId,
    required String pollId,
  }) async {
    return await repository.deletePoll(tripId: tripId, pollId: pollId);
  }
}

class CastVoteUseCase {
  final PollRepository repository;
  CastVoteUseCase(this.repository);

  Future<PollEntity> call({
    required String tripId,
    required String pollId,
    required String optionId,
  }) async {
    return await repository.castVote(
      tripId: tripId,
      pollId: pollId,
      optionId: optionId,
    );
  }
}

class ClosePollUseCase {
  final PollRepository repository;
  ClosePollUseCase(this.repository);

  Future<PollEntity> call({
    required String tripId,
    required String pollId,
  }) async {
    return await repository.closePoll(tripId: tripId, pollId: pollId);
  }
}
