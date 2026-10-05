import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/friend_model.dart';

abstract class FriendRemoteDataSource {
  Future<List<FriendModel>> getFriends();
  Future<List<FriendRequestModel>> getPendingRequests();
  Future<FriendRequestModel> sendFriendRequest(String username);
  Future<FriendRequestModel> respondToFriendRequest(String friendshipId, String action);
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final Dio dio;

  FriendRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FriendModel>> getFriends() async {
    debugPrint('[FRIEND_REMOTE_DS] 👥 GET ${ApiConstants.friends}');
    try {
      final response = await dio.get(ApiConstants.friends);
      debugPrint('[FRIEND_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['friends'] ?? [];
        return list.map((item) => FriendModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch friends list',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[FRIEND_REMOTE_DS] ❌ DioError GET /friends: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error fetching friends',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<FriendRequestModel>> getPendingRequests() async {
    debugPrint('[FRIEND_REMOTE_DS] 📩 GET ${ApiConstants.friendRequests}');
    try {
      final response = await dio.get(ApiConstants.friendRequests);
      debugPrint('[FRIEND_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['requests'] ?? [];
        return list.map((item) => FriendRequestModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch friend requests',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[FRIEND_REMOTE_DS] ❌ DioError GET /friend/requests: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error fetching friend requests',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<FriendRequestModel> sendFriendRequest(String username) async {
    debugPrint('[FRIEND_REMOTE_DS] 🤝 POST ${ApiConstants.friendRequest} -> username: $username');
    try {
      final response = await dio.post(
        ApiConstants.friendRequest,
        data: {'username': username},
      );
      debugPrint('[FRIEND_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['status'] == 'success') {
        final data = response.data['data']['friendship'];
        return FriendRequestModel.fromJson(data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to send friend request',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[FRIEND_REMOTE_DS] ❌ DioError POST /friends/request: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error sending friend request',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<FriendRequestModel> respondToFriendRequest(String friendshipId, String action) async {
    final endpoint = '${ApiConstants.friendRequest}/$friendshipId';
    debugPrint('[FRIEND_REMOTE_DS] ✏️ PATCH $endpoint -> action: $action');
    try {
      final response = await dio.patch(
        endpoint,
        data: {'action': action},
      );
      debugPrint('[FRIEND_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data']['friendship'];
        return FriendRequestModel.fromJson(data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to respond to friend request',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[FRIEND_REMOTE_DS] ❌ DioError PATCH /friend/request: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error responding to request',
        e.response?.statusCode,
      );
    }
  }
}
