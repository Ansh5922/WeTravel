import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;
  GetChatMessagesUseCase(this.repository);

  Future<List<ChatMessageEntity>> call(String tripId, {String? before}) async {
    return await repository.getMessages(tripId, before: before);
  }
}

class GetImageKitAuthUseCase {
  final ChatRepository repository;
  GetImageKitAuthUseCase(this.repository);

  Future<ImageKitAuthEntity> call(String tripId) async {
    return await repository.getImageKitAuth(tripId);
  }
}

class SendImageMessageUseCase {
  final ChatRepository repository;
  SendImageMessageUseCase(this.repository);

  Future<ChatMessageEntity> call({
    required String tripId,
    required String imageUrl,
    String? fileName,
  }) async {
    return await repository.sendImageMessage(
      tripId: tripId,
      imageUrl: imageUrl,
      fileName: fileName,
    );
  }
}
