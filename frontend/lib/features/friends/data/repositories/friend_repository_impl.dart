import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friend_remote_data_source.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  FriendRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FriendEntity>> getFriends() async {
    try {
      return await remoteDataSource.getFriends();
    } on ServerException catch (e) {
      debugPrint('[FRIEND_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FRIEND_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch friends: ${e.toString()}');
    }
  }

  @override
  Future<List<FriendRequestEntity>> getPendingRequests() async {
    try {
      return await remoteDataSource.getPendingRequests();
    } on ServerException catch (e) {
      debugPrint('[FRIEND_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FRIEND_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch friend requests: ${e.toString()}');
    }
  }

  @override
  Future<FriendRequestEntity> sendFriendRequest(String username) async {
    try {
      return await remoteDataSource.sendFriendRequest(username);
    } on ServerException catch (e) {
      debugPrint('[FRIEND_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FRIEND_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to send friend request: ${e.toString()}');
    }
  }

  @override
  Future<FriendRequestEntity> respondToFriendRequest(String friendshipId, String action) async {
    try {
      return await remoteDataSource.respondToFriendRequest(friendshipId, action);
    } on ServerException catch (e) {
      debugPrint('[FRIEND_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FRIEND_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to respond to request: ${e.toString()}');
    }
  }
}
