import '../../domain/entities/friend_entity.dart';

class FriendModel extends FriendEntity {
  const FriendModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.fullName,
    super.avatarUrl,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['friend'] ?? json['user'] ?? json;
    return FriendModel(
      id: json['id'] ?? userMap['id'] ?? '',
      userId: userMap['id'] ?? json['userId'] ?? '',
      username: userMap['username'] ?? '',
      fullName: userMap['fullName'] ?? userMap['username'] ?? 'WeTravel User',
      avatarUrl: userMap['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
    };
  }
}

class FriendRequestModel extends FriendRequestEntity {
  const FriendRequestModel({
    required super.id,
    required super.requesterId,
    required super.addresseeId,
    required super.status,
    required super.requesterUsername,
    required super.requesterFullName,
    super.requesterAvatarUrl,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    final reqUser = json['requester'] ?? {};
    return FriendRequestModel(
      id: json['id'] ?? '',
      requesterId: json['requesterId'] ?? reqUser['id'] ?? '',
      addresseeId: json['addresseeId'] ?? '',
      status: json['status'] ?? 'pending',
      requesterUsername: reqUser['username'] ?? 'User',
      requesterFullName: reqUser['fullName'] ?? reqUser['username'] ?? 'WeTravel User',
      requesterAvatarUrl: reqUser['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'addresseeId': addresseeId,
      'status': status,
      'requester': {
        'username': requesterUsername,
        'fullName': requesterFullName,
        'avatarUrl': requesterAvatarUrl,
      },
    };
  }
}
