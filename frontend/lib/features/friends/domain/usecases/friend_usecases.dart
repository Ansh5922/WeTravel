import '../entities/friend_entity.dart';
import '../repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;
  GetFriendsUseCase(this.repository);

  Future<List<FriendEntity>> call() async {
    return await repository.getFriends();
  }
}

class GetPendingFriendRequestsUseCase {
  final FriendRepository repository;
  GetPendingFriendRequestsUseCase(this.repository);

  Future<List<FriendRequestEntity>> call() async {
    return await repository.getPendingRequests();
  }
}

class SendFriendRequestUseCase {
  final FriendRepository repository;
  SendFriendRequestUseCase(this.repository);

  Future<FriendRequestEntity> call(String username) async {
    return await repository.sendFriendRequest(username);
  }
}

class RespondFriendRequestUseCase {
  final FriendRepository repository;
  RespondFriendRequestUseCase(this.repository);

  Future<FriendRequestEntity> call(String friendshipId, String action) async {
    return await repository.respondToFriendRequest(friendshipId, action);
  }
}
