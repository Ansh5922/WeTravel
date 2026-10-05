import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(String tripId, {String? before});
  Future<ImageKitAuthEntity> getImageKitAuth(String tripId);
  Future<ChatMessageEntity> sendImageMessage({
    required String tripId,
    required String imageUrl,
    String? fileName,
  });

  Stream<ChatMessageEntity> connectWebSocket({
    required String tripId,
    required String token,
  });
  void sendWsTextMessage(String content);
  void sendWsImageMessage({required String imageUrl, String? fileName});
  void sendWsTypingIndicator();
  void disconnectWebSocket();
}
