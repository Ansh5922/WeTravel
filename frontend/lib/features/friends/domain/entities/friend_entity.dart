import 'package:equatable/equatable.dart';

class FriendEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String fullName;
  final String? avatarUrl;

  const FriendEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, userId, username, fullName, avatarUrl];
}

class FriendRequestEntity extends Equatable {
  final String id;
  final String requesterId;
  final String addresseeId;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final String requesterUsername;
  final String requesterFullName;
  final String? requesterAvatarUrl;

  const FriendRequestEntity({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.requesterUsername,
    required this.requesterFullName,
    this.requesterAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        requesterId,
        addresseeId,
        status,
        requesterUsername,
        requesterFullName,
        requesterAvatarUrl,
      ];
}

class SentFriendRequestEntity extends Equatable {
  final String id;
  final String requesterId;
  final String receiverId;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final String receiverUsername;
  final String receiverFullName;
  final String? receiverAvatarUrl;
  final DateTime? createdAt;

  const SentFriendRequestEntity({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.receiverUsername,
    required this.receiverFullName,
    this.receiverAvatarUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        requesterId,
        receiverId,
        status,
        receiverUsername,
        receiverFullName,
        receiverAvatarUrl,
        createdAt,
      ];
}
