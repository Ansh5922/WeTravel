import 'package:equatable/equatable.dart';

class ChatSenderEntity extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;

  const ChatSenderEntity({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl];
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String groupId;
  final String senderId;
  final String messageType; // 'text' | 'image' | 'system'
  final String content;
  final String? imageUrl;
  final ChatSenderEntity? sender;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.messageType,
    required this.content,
    this.imageUrl,
    this.sender,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        senderId,
        messageType,
        content,
        imageUrl,
        sender,
        createdAt,
      ];
}

class ImageKitAuthEntity extends Equatable {
  final String token;
  final int expire;
  final String signature;

  const ImageKitAuthEntity({
    required this.token,
    required this.expire,
    required this.signature,
  });

  @override
  List<Object?> get props => [token, expire, signature];
}
