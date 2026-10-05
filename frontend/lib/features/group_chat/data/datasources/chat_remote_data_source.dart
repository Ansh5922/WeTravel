import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getMessages(String tripId, {String? before});
  Future<ImageKitAuthModel> getImageKitAuth(String tripId);
  Future<ChatMessageModel> sendImageMessage({
    required String tripId,
    required String imageUrl,
    String? fileName,
  });

  Stream<ChatMessageModel> connectWebSocket({
    required String tripId,
    required String token,
  });
  void sendWsTextMessage(String content);
  void sendWsImageMessage({required String imageUrl, String? fileName});
  void sendWsTypingIndicator();
  void disconnectWebSocket();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  WebSocket? _webSocket;
  StreamController<ChatMessageModel>? _wsStreamController;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChatMessageModel>> getMessages(String tripId, {String? before}) async {
    final path = '/api/trips/$tripId/chat/messages';
    final queryParams = before != null ? {'before': before} : null;
    debugPrint('[CHAT_REMOTE_DS] 💬 GET $path (params: $queryParams)');

    try {
      final response = await dio.get(path, queryParameters: queryParams);
      debugPrint('[CHAT_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List list = response.data['data']['messages'] ?? [];
        return list.map((item) => ChatMessageModel.fromJson(item)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch chat messages',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[CHAT_REMOTE_DS] ❌ DioError GET messages: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error fetching messages',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<ImageKitAuthModel> getImageKitAuth(String tripId) async {
    final path = '/api/trips/$tripId/chat/imagekit-auth';
    debugPrint('[CHAT_REMOTE_DS] 🔑 GET $path');

    try {
      final response = await dio.get(path);
      debugPrint('[CHAT_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return ImageKitAuthModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get ImageKit auth',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[CHAT_REMOTE_DS] ❌ DioError GET imagekit-auth: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error getting imagekit auth',
        e.response?.statusCode,
      );
    }
  }

  @override
  Future<ChatMessageModel> sendImageMessage({
    required String tripId,
    required String imageUrl,
    String? fileName,
  }) async {
    final path = '/api/trips/$tripId/chat/image';
    debugPrint('[CHAT_REMOTE_DS] 📷 POST $path -> imageUrl: $imageUrl');

    try {
      final response = await dio.post(
        path,
        data: {
          'imageUrl': imageUrl,
          'fileName': fileName ?? 'Uploaded Image',
        },
      );
      debugPrint('[CHAT_REMOTE_DS] 📥 Res: ${response.statusCode} -> ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['status'] == 'success') {
        return ChatMessageModel.fromJson(response.data['data']['message']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to confirm image message',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('[CHAT_REMOTE_DS] ❌ DioError POST image: ${e.message}');
      throw ServerException(
        e.response?.data?['message'] ?? 'Network error sending image',
        e.response?.statusCode,
      );
    }
  }

  @override
  Stream<ChatMessageModel> connectWebSocket({
    required String tripId,
    required String token,
  }) {
    disconnectWebSocket();
    _wsStreamController = StreamController<ChatMessageModel>.broadcast();

    final wsUrl = '${ApiConstants.wsBaseUrl}?token=$token&tripId=$tripId';
    debugPrint('[CHAT_WS] 🔌 Connecting WebSocket to $wsUrl');

    WebSocket.connect(wsUrl).then((ws) {
      _webSocket = ws;
      debugPrint('[CHAT_WS] ✅ WebSocket Connected!');

      ws.listen(
        (data) {
          debugPrint('[CHAT_WS] 📩 Received WS Raw: $data');
          try {
            final Map<String, dynamic> json = jsonDecode(data.toString());
            final type = json['type'];
            if (type == 'message' || type == 'image') {
              final model = ChatMessageModel.fromJson(json);
              _wsStreamController?.add(model);
            }
          } catch (e) {
            debugPrint('[CHAT_WS] 💥 JSON parse error: $e');
          }
        },
        onError: (err) {
          debugPrint('[CHAT_WS] ❌ WebSocket Error: $err');
          _wsStreamController?.addError(err);
        },
        onDone: () {
          debugPrint('[CHAT_WS] 🔌 WebSocket Closed');
        },
      );
    }).catchError((e) {
      debugPrint('[CHAT_WS] ❌ WebSocket Connection Failed: $e');
      _wsStreamController?.addError(e);
    });

    return _wsStreamController!.stream;
  }

  @override
  void sendWsTextMessage(String content) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final payload = jsonEncode({'type': 'message', 'content': content});
      debugPrint('[CHAT_WS] 📤 Sending WS Message: $payload');
      _webSocket!.add(payload);
    } else {
      debugPrint('[CHAT_WS] ⚠️ Cannot send text message: WebSocket is not open.');
    }
  }

  @override
  void sendWsImageMessage({required String imageUrl, String? fileName}) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final payload = jsonEncode({
        'type': 'image',
        'imageUrl': imageUrl,
        'fileName': fileName ?? 'Image',
      });
      debugPrint('[CHAT_WS] 📤 Sending WS Image: $payload');
      _webSocket!.add(payload);
    } else {
      debugPrint('[CHAT_WS] ⚠️ Cannot send image message: WebSocket is not open.');
    }
  }

  @override
  void sendWsTypingIndicator() {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final payload = jsonEncode({'type': 'typing'});
      debugPrint('[CHAT_WS] 📤 Sending WS Typing indicator');
      _webSocket!.add(payload);
    }
  }

  @override
  void disconnectWebSocket() {
    _webSocket?.close();
    _webSocket = null;
    _wsStreamController?.close();
    _wsStreamController = null;
    debugPrint('[CHAT_WS] 🔌 Disconnected and cleaned up WebSocket.');
  }
}
