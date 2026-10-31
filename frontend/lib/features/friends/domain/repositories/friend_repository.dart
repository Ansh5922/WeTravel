import '../entities/friend_entity.dart';

abstract class FriendRepository {
  Future<List<FriendEntity>> getFriends();
  Future<List<FriendRequestEntity>> getPendingRequests();
  Future<List<SentFriendRequestEntity>> getSentRequests();
  Future<FriendRequestEntity> sendFriendRequest(String username);
  Future<FriendRequestEntity> respondToFriendRequest(String friendshipId, String action);
}
