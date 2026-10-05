import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/polls/data/models/poll_model.dart';
import 'package:frontend/features/polls/domain/entities/poll_entity.dart';
import 'package:frontend/features/polls/domain/repositories/poll_repository.dart';
import 'package:frontend/features/polls/domain/usecases/poll_usecases.dart';
import 'package:frontend/features/polls/presentation/bloc/poll_bloc.dart';
import 'package:frontend/features/polls/presentation/bloc/poll_event.dart';
import 'package:frontend/features/polls/presentation/bloc/poll_state.dart';

class FakePollRepository implements PollRepository {
  List<PollEntity>? pollsToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<PollEntity>> getPolls(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return pollsToReturn ??
        [
          PollEntity(
            id: 'poll_1',
            groupId: tripId,
            creatorId: 'usr_1',
            question: 'Where should we eat tonight?',
            isClosed: false,
            options: const [
              PollOptionEntity(id: 'opt_1', pollId: 'poll_1', optionText: 'Seafood', voteCount: 3),
              PollOptionEntity(id: 'opt_2', pollId: 'poll_1', optionText: 'Italian', voteCount: 1),
            ],
            userVotedOptionId: 'opt_1',
            createdAt: DateTime.now(),
          )
        ];
  }

  @override
  Future<PollEntity> createPoll({
    required String tripId,
    required String question,
    required List<String> options,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return PollEntity(
      id: 'poll_2',
      groupId: tripId,
      creatorId: 'usr_1',
      question: question,
      isClosed: false,
      options: options.map((opt) => PollOptionEntity(id: 'opt_new', pollId: 'poll_2', optionText: opt, voteCount: 0)).toList(),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PollEntity> castVote({
    required String tripId,
    required String pollId,
    required String optionId,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return PollEntity(
      id: pollId,
      groupId: tripId,
      creatorId: 'usr_1',
      question: 'Where should we eat tonight?',
      isClosed: false,
      options: const [
        PollOptionEntity(id: 'opt_1', pollId: 'poll_1', optionText: 'Seafood', voteCount: 4),
      ],
      userVotedOptionId: optionId,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PollEntity> closePoll({
    required String tripId,
    required String pollId,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return PollEntity(
      id: pollId,
      groupId: tripId,
      creatorId: 'usr_1',
      question: 'Where should we eat tonight?',
      isClosed: true,
      options: const [
        PollOptionEntity(id: 'opt_1', pollId: 'poll_1', optionText: 'Seafood', voteCount: 4),
      ],
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  group('PollModel JSON Parsing', () {
    test('PollModel.fromJson parses poll payload with options', () {
      final json = {
        'id': 'poll_10',
        'groupId': 'trip_1',
        'creatorId': 'usr_3',
        'question': 'Which activity first?',
        'isClosed': false,
        'createdAt': '2026-10-05T15:00:00.000Z',
        'options': [
          {'id': 'opt_10', 'pollId': 'poll_10', 'optionText': 'Scuba Diving', '_count': {'votes': 5}},
          {'id': 'opt_11', 'pollId': 'poll_10', 'optionText': 'Parasailing', '_count': {'votes': 2}}
        ]
      };

      final model = PollModel.fromJson(json);

      expect(model.id, 'poll_10');
      expect(model.question, 'Which activity first?');
      expect(model.options.length, 2);
      expect(model.options.first.voteCount, 5);
    });
  });

  group('PollBloc Unit Tests', () {
    late FakePollRepository fakeRepository;
    late PollBloc pollBloc;

    setUp(() {
      fakeRepository = FakePollRepository();
      pollBloc = PollBloc(
        getPollsUseCase: GetPollsUseCase(fakeRepository),
        createPollUseCase: CreatePollUseCase(fakeRepository),
        castVoteUseCase: CastVoteUseCase(fakeRepository),
        closePollUseCase: ClosePollUseCase(fakeRepository),
      );
    });

    tearDown(() {
      pollBloc.close();
    });

    test('initial state is PollInitialState', () {
      expect(pollBloc.state, isA<PollInitialState>());
    });

    test('PollsFetchRequested success emits PollsLoadedState', () async {
      pollBloc.add(const PollsFetchRequested(tripId: 'trip_1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(pollBloc.state, isA<PollsLoadedState>());
      final loaded = pollBloc.state as PollsLoadedState;
      expect(loaded.polls.length, 1);
      expect(loaded.polls.first.question, contains('eat tonight'));
    });

    test('PollCreateRequested creates poll and emits updated list', () async {
      pollBloc.add(const PollCreateRequested(
        tripId: 'trip_1',
        question: 'Best time for dinner?',
        options: ['7 PM', '8 PM'],
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(pollBloc.state, isA<PollsLoadedState>());
      final loaded = pollBloc.state as PollsLoadedState;
      expect(loaded.successMessage, 'Poll created.');
    });
  });
}
