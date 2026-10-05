import '../../domain/entities/chat_message_entity.dart';

class ChatSenderModel extends ChatSenderEntity {
  const ChatSenderModel({
    required super.id,
    required super.username,
    required super.fullName,
    super.avatarUrl,
  });

  factory ChatSenderModel.fromJson(Map<String, dynamic> json) {
    return ChatSenderModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? json['username'] ?? 'Member',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
    };
  }
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.groupId,
    required super.senderId,
    required super.messageType,
    required super.content,
    super.imageUrl,
    super.sender,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderJson = json['sender'];
    ChatSenderModel? senderModel;
    if (senderJson is Map<String, dynamic>) {
      senderModel = ChatSenderModel.fromJson(senderJson);
    }

    return ChatMessageModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? json['tripId'] ?? '',
      senderId: json['senderId'] ?? senderModel?.id ?? '',
      messageType: json['messageType'] ?? json['type'] ?? 'text',
      content: json['content'] ?? json['fileName'] ?? '',
      imageUrl: json['imageUrl'],
      sender: senderModel,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'messageType': messageType,
      'content': content,
      'imageUrl': imageUrl,
      'sender': sender != null
          ? (sender as ChatSenderModel).toJson()
          : null,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ImageKitAuthModel extends ImageKitAuthEntity {
  const ImageKitAuthModel({
    required super.token,
    required super.expire,
    required super.signature,
  });

  factory ImageKitAuthModel.fromJson(Map<String, dynamic> json) {
    return ImageKitAuthModel(
      token: json['token'] ?? '',
      expire: json['expire'] is int ? json['expire'] : int.tryParse(json['expire']?.toString() ?? '0') ?? 0,
      signature: json['signature'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expire': expire,
      'signature': signature,
    };
  }
}
