import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/group_chat/data/models/chat_message_model.dart';
import 'package:frontend/features/group_chat/domain/entities/chat_message_entity.dart';
import 'package:frontend/features/group_chat/domain/repositories/chat_repository.dart';
import 'package:frontend/features/group_chat/domain/usecases/chat_usecases.dart';
import 'package:frontend/features/group_chat/presentation/bloc/chat_bloc.dart';
import 'package:frontend/features/group_chat/presentation/bloc/chat_event.dart';
import 'package:frontend/features/group_chat/presentation/bloc/chat_state.dart';

class FakeChatRepository implements ChatRepository {
  List<ChatMessageEntity>? messagesToReturn;
  ImageKitAuthEntity? imageKitToReturn;
  final _controller = StreamController<ChatMessageEntity>.broadcast();
  Exception? exceptionToThrow;

  @override
  Future<List<ChatMessageEntity>> getMessages(String tripId, {String? before}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return messagesToReturn ??
        [
          ChatMessageEntity(
            id: 'msg_1',
            groupId: tripId,
            senderId: 'usr_1',
            messageType: 'text',
            content: 'Hey everyone!',
            createdAt: DateTime.now(),
          )
        ];
  }

  @override
  Future<ImageKitAuthEntity> getImageKitAuth(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return imageKitToReturn ??
        const ImageKitAuthEntity(
          token: 'token_ik',
          expire: 1700000000,
          signature: 'sig_ik',
        );
  }

  @override
  Future<ChatMessageEntity> sendImageMessage({
    required String tripId,
    required String imageUrl,
    String? fileName,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return ChatMessageEntity(
      id: 'msg_img_1',
      groupId: tripId,
      senderId: 'usr_1',
      messageType: 'image',
      content: fileName ?? 'Image',
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<ChatMessageEntity> connectWebSocket({
    required String tripId,
    required String token,
  }) {
    return _controller.stream;
  }

  @override
  void sendWsTextMessage(String content) {}

  @override
  void sendWsImageMessage({required String imageUrl, String? fileName}) {}

  @override
  void sendWsTypingIndicator() {}

  @override
  void disconnectWebSocket() {
    _controller.close();
  }
}

void main() {
  group('ChatMessageModel JSON Parsing', () {
    test('ChatMessageModel.fromJson parses message payload', () {
      final json = {
        'id': 'msg_99',
        'groupId': 'trip_10',
        'senderId': 'usr_5',
        'messageType': 'text',
        'content': 'Meeting at 5 PM',
        'createdAt': '2026-10-05T10:00:00.000Z',
        'sender': {'id': 'usr_5', 'username': 'rashi', 'fullName': 'Rashi'}
      };

      final model = ChatMessageModel.fromJson(json);

      expect(model.id, 'msg_99');
      expect(model.content, 'Meeting at 5 PM');
      expect(model.sender?.fullName, 'Rashi');
    });
  });

  group('ChatBloc Unit Tests', () {
    late FakeChatRepository fakeRepository;
    late ChatBloc chatBloc;

    setUp(() {
      fakeRepository = FakeChatRepository();
      chatBloc = ChatBloc(
        getChatMessagesUseCase: GetChatMessagesUseCase(fakeRepository),
        getImageKitAuthUseCase: GetImageKitAuthUseCase(fakeRepository),
        sendImageMessageUseCase: SendImageMessageUseCase(fakeRepository),
        repository: fakeRepository,
      );
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initial state is ChatInitialState', () {
      expect(chatBloc.state, isA<ChatInitialState>());
    });

    test('ChatMessagesFetchRequested success emits ChatLoadedState', () async {
      chatBloc.add(const ChatMessagesFetchRequested(tripId: 'trip_10'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(chatBloc.state, isA<ChatLoadedState>());
      final loaded = chatBloc.state as ChatLoadedState;
      expect(loaded.messages.length, 1);
      expect(loaded.messages.first.content, 'Hey everyone!');
    });
  });
}
