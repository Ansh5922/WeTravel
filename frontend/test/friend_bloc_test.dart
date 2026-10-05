import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/friends/data/models/friend_model.dart';
import 'package:frontend/features/friends/domain/entities/friend_entity.dart';
import 'package:frontend/features/friends/domain/repositories/friend_repository.dart';
import 'package:frontend/features/friends/domain/usecases/friend_usecases.dart';
import 'package:frontend/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:frontend/features/friends/presentation/bloc/friend_event.dart';
import 'package:frontend/features/friends/presentation/bloc/friend_state.dart';

class FakeFriendRepository implements FriendRepository {
  List<FriendEntity>? friendsToReturn;
  List<FriendRequestEntity>? requestsToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<FriendEntity>> getFriends() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return friendsToReturn ??
        const [
          FriendEntity(
            id: 'f_1',
            userId: 'usr_2',
            username: 'alex',
            fullName: 'Alex Smith',
          )
        ];
  }

  @override
  Future<List<FriendRequestEntity>> getPendingRequests() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return requestsToReturn ??
        const [
          FriendRequestEntity(
            id: 'fr_1',
            requesterId: 'usr_3',
            addresseeId: 'usr_1',
            status: 'pending',
            requesterUsername: 'sam',
            requesterFullName: 'Sam Wilson',
          )
        ];
  }

  @override
  Future<FriendRequestEntity> sendFriendRequest(String username) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return FriendRequestEntity(
      id: 'fr_new',
      requesterId: 'usr_1',
      addresseeId: 'usr_target',
      status: 'pending',
      requesterUsername: 'me',
      requesterFullName: 'Me',
    );
  }

  @override
  Future<FriendRequestEntity> respondToFriendRequest(String friendshipId, String action) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return FriendRequestEntity(
      id: friendshipId,
      requesterId: 'usr_3',
      addresseeId: 'usr_1',
      status: action == 'accept' ? 'accepted' : 'rejected',
      requesterUsername: 'sam',
      requesterFullName: 'Sam Wilson',
    );
  }
}

void main() {
  group('FriendModel JSON Parsing', () {
    test('FriendModel.fromJson parses friend payload', () {
      final json = {
        'id': 'f_100',
        'userId': 'usr_50',
        'friend': {
          'id': 'usr_50',
          'username': 'john_doe',
          'fullName': 'John Doe',
          'avatarUrl': 'https://example.com/avatar.jpg'
        }
      };

      final model = FriendModel.fromJson(json);

      expect(model.id, 'f_100');
      expect(model.username, 'john_doe');
      expect(model.fullName, 'John Doe');
      expect(model.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });

  group('FriendBloc Unit Tests', () {
    late FakeFriendRepository fakeRepository;
    late FriendBloc friendBloc;

    setUp(() {
      fakeRepository = FakeFriendRepository();
      friendBloc = FriendBloc(
        getFriendsUseCase: GetFriendsUseCase(fakeRepository),
        getPendingFriendRequestsUseCase: GetPendingFriendRequestsUseCase(fakeRepository),
        sendFriendRequestUseCase: SendFriendRequestUseCase(fakeRepository),
        respondFriendRequestUseCase: RespondFriendRequestUseCase(fakeRepository),
      );
    });

    tearDown(() {
      friendBloc.close();
    });

    test('initial state is FriendInitialState', () {
      expect(friendBloc.state, isA<FriendInitialState>());
    });

    test('FriendsFetchRequested success emits FriendsLoadedState', () async {
      friendBloc.add(const FriendsFetchRequested());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(friendBloc.state, isA<FriendsLoadedState>());
      final loaded = friendBloc.state as FriendsLoadedState;
      expect(loaded.friends.length, 1);
      expect(loaded.pendingRequests.length, 1);
    });

    test('FriendSendRequestRequested sends request and refreshes lists', () async {
      friendBloc.add(const FriendSendRequestRequested('sam'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(friendBloc.state, isA<FriendsLoadedState>());
      final loaded = friendBloc.state as FriendsLoadedState;
      expect(loaded.successMessage, contains('Friend request sent'));
    });
  });
}
