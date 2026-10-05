import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatMessageEntity>> getMessages(String tripId, {String? before}) async {
    try {
      return await remoteDataSource.getMessages(tripId, before: before);
    } on ServerException catch (e) {
      debugPrint('[CHAT_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[CHAT_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch chat messages: ${e.toString()}');
    }
  }

  @override
  Future<ImageKitAuthEntity> getImageKitAuth(String tripId) async {
    try {
      return await remoteDataSource.getImageKitAuth(tripId);
    } on ServerException catch (e) {
      debugPrint('[CHAT_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[CHAT_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to fetch ImageKit auth: ${e.toString()}');
    }
  }

  @override
  Future<ChatMessageEntity> sendImageMessage({
    required String tripId,
    required String imageUrl,
    String? fileName,
  }) async {
    try {
      return await remoteDataSource.sendImageMessage(
        tripId: tripId,
        imageUrl: imageUrl,
        fileName: fileName,
      );
    } on ServerException catch (e) {
      debugPrint('[CHAT_REPO] ❌ ServerException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[CHAT_REPO] 💥 Unexpected Exception: $e');
      throw ServerException('Failed to send image message: ${e.toString()}');
    }
  }

  @override
  Stream<ChatMessageEntity> connectWebSocket({
    required String tripId,
    required String token,
  }) {
    return remoteDataSource.connectWebSocket(tripId: tripId, token: token);
  }

  @override
  void sendWsTextMessage(String content) {
    remoteDataSource.sendWsTextMessage(content);
  }

  @override
  void sendWsImageMessage({required String imageUrl, String? fileName}) {
    remoteDataSource.sendWsImageMessage(imageUrl: imageUrl, fileName: fileName);
  }

  @override
  void sendWsTypingIndicator() {
    remoteDataSource.sendWsTypingIndicator();
  }

  @override
  void disconnectWebSocket() {
    remoteDataSource.disconnectWebSocket();
  }
}
