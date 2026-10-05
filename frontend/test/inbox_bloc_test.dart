import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/inbox/data/models/inbox_invite_model.dart';
import 'package:frontend/features/inbox/domain/entities/inbox_invite_entity.dart';
import 'package:frontend/features/inbox/domain/repositories/inbox_repository.dart';
import 'package:frontend/features/inbox/domain/usecases/get_my_invites_usecase.dart';
import 'package:frontend/features/inbox/domain/usecases/respond_to_invite_usecase.dart';
import 'package:frontend/features/inbox/presentation/bloc/inbox_bloc.dart';
import 'package:frontend/features/inbox/presentation/bloc/inbox_event.dart';
import 'package:frontend/features/inbox/presentation/bloc/inbox_state.dart';

class FakeInboxRepository implements InboxRepository {
  List<InboxInviteEntity>? invitesToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<InboxInviteEntity>> getMyInvites() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return invitesToReturn ??
        const [
          InboxInviteEntity(
            id: 'inv_1',
            groupId: 'group_1',
            groupName: 'Goa Trip',
            invitedById: 'usr_2',
            inviterUsername: 'sam',
            inviterFullName: 'Sam Wilson',
            inviteType: 'friend',
            inviteToken: 'token_123',
            status: InboxInviteStatus.pending,
          ),
        ];
  }

  @override
  Future<String> respondToInvite({
    required String inviteId,
    required String action,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return action == 'accept' ? 'Joined Goa Trip!' : 'Invitation rejected.';
  }
}

void main() {
  group('InboxInviteModel JSON Parsing', () {
    test('fromJson correctly parses backend invite JSON', () {
      final json = {
        'id': 'inv_10',
        'groupId': 'grp_20',
        'invitedBy': 'usr_30',
        'inviteType': 'friend',
        'inviteToken': 'abc_token',
        'status': 'pending',
        'group': {'id': 'grp_20', 'name': 'Himalayan Trek'},
        'inviter': {
          'id': 'usr_30',
          'email': 'hiker@test.com',
          'username': 'hiker',
          'fullName': 'John Hiker'
        },
      };

      final model = InboxInviteModel.fromJson(json);

      expect(model.id, 'inv_10');
      expect(model.groupId, 'grp_20');
      expect(model.groupName, 'Himalayan Trek');
      expect(model.inviterFullName, 'John Hiker');
      expect(model.status, InboxInviteStatus.pending);
    });
  });

  group('InboxBloc Unit Tests', () {
    late FakeInboxRepository fakeRepository;
    late InboxBloc inboxBloc;

    setUp(() {
      fakeRepository = FakeInboxRepository();
      inboxBloc = InboxBloc(
        getMyInvitesUseCase: GetMyInvitesUseCase(fakeRepository),
        respondToInviteUseCase: RespondToInviteUseCase(fakeRepository),
      );
    });

    tearDown(() {
      inboxBloc.close();
    });

    test('initial state is InboxInitialState', () {
      expect(inboxBloc.state, isA<InboxInitialState>());
    });

    test('InboxFetchRequested success emits InboxLoadedState', () async {
      inboxBloc.add(InboxFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(inboxBloc.state, isA<InboxLoadedState>());
      final loaded = inboxBloc.state as InboxLoadedState;
      expect(loaded.allInvites.length, 1);
      expect(loaded.pendingCount, 1);
    });

    test('InboxInviteAccepted updates status to accepted', () async {
      inboxBloc.add(InboxFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      inboxBloc.add(const InboxInviteAccepted('inv_1'));
      await Future.delayed(const Duration(milliseconds: 50));

      final loaded = inboxBloc.state as InboxLoadedState;
      expect(loaded.allInvites.first.status, InboxInviteStatus.accepted);
      expect(loaded.acceptedCount, 1);
      expect(loaded.pendingCount, 0);
    });
  });
}
