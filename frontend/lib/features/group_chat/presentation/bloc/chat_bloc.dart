import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatMessagesUseCase getChatMessagesUseCase;
  final GetImageKitAuthUseCase getImageKitAuthUseCase;
  final SendImageMessageUseCase sendImageMessageUseCase;
  final ChatRepository repository;

  StreamSubscription<ChatMessageEntity>? _wsSubscription;

  ChatBloc({
    required this.getChatMessagesUseCase,
    required this.getImageKitAuthUseCase,
    required this.sendImageMessageUseCase,
    required this.repository,
  }) : super(ChatInitialState()) {
    on<ChatMessagesFetchRequested>(_onChatMessagesFetchRequested);
    on<ChatConnectWebSocketRequested>(_onChatConnectWebSocketRequested);
    on<ChatSendTextMessageRequested>(_onChatSendTextMessageRequested);
    on<ChatSendImageMessageRequested>(_onChatSendImageMessageRequested);
    on<ChatDisconnectWebSocketRequested>(_onChatDisconnectWebSocketRequested);
    on<ChatMessageReceived>(_onChatMessageReceived);
    on<ChatWsConnectionChanged>(_onChatWsConnectionChanged);
  }

  void _onChatMessageReceived(
    ChatMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoadedState) {
      final current = state as ChatLoadedState;
      // If message ID already exists, do not duplicate
      if (event.message.id.isNotEmpty && current.messages.any((m) => m.id == event.message.id)) {
        return;
      }

      // Check if replacing an optimistic temporary message with matching content
      final tempIndex = current.messages.indexWhere(
        (m) => m.id.startsWith('temp_') && m.content == event.message.content,
      );

      List<ChatMessageEntity> updated;
      if (tempIndex != -1) {
        updated = List<ChatMessageEntity>.from(current.messages)..[tempIndex] = event.message;
      } else {
        updated = List<ChatMessageEntity>.from(current.messages)..add(event.message);
      }

      emit(current.copyWith(messages: updated, isWsConnected: true));
    }
  }

  void _onChatWsConnectionChanged(
    ChatWsConnectionChanged event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoadedState) {
      emit((state as ChatLoadedState).copyWith(
        isWsConnected: event.isConnected,
        error: event.error,
      ));
    }
  }

  Future<void> _onChatMessagesFetchRequested(
    ChatMessagesFetchRequested event,
    Emitter<ChatState> emit,
  ) async {
    debugPrint('[CHAT_BLOC] 💬 Event: ChatMessagesFetchRequested (tripId: ${event.tripId})');
    emit(ChatLoadingState());

    try {
      final messages = await getChatMessagesUseCase(event.tripId, before: event.before);
      debugPrint('[CHAT_BLOC] ✅ Loaded ${messages.length} message(s)');
      emit(ChatLoadedState(messages: messages));
    } on ServerException catch (e) {
      debugPrint('[CHAT_BLOC] ❌ Messages Fetch Error: ${e.message}');
      emit(ChatErrorState(message: e.message));
    } catch (e) {
      debugPrint('[CHAT_BLOC] 💥 Unexpected Messages Fetch Error: $e');
      emit(ChatErrorState(message: 'Failed to fetch messages: ${e.toString()}'));
    }
  }

  Future<void> _onChatConnectWebSocketRequested(
    ChatConnectWebSocketRequested event,
    Emitter<ChatState> emit,
  ) async {
    debugPrint('[CHAT_BLOC] 🔌 Event: ChatConnectWebSocketRequested (tripId: ${event.tripId})');

    await _wsSubscription?.cancel();
    final stream = repository.connectWebSocket(tripId: event.tripId, token: event.token);

    _wsSubscription = stream.listen(
      (newMsg) {
        debugPrint('[CHAT_BLOC] 📩 WS Stream received new message: "${newMsg.content}"');
        add(ChatMessageReceived(newMsg));
      },
      onError: (err) {
        debugPrint('[CHAT_BLOC] ❌ WS Stream error: $err');
        add(ChatWsConnectionChanged(isConnected: false, error: err.toString()));
      },
      onDone: () {
        debugPrint('[CHAT_BLOC] 🔌 WS Stream closed');
        add(const ChatWsConnectionChanged(isConnected: false));
      },
    );

    if (state is ChatLoadedState) {
      emit((state as ChatLoadedState).copyWith(isWsConnected: true));
    }
  }

  void _onChatSendTextMessageRequested(
    ChatSendTextMessageRequested event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[CHAT_BLOC] 📤 Event: ChatSendTextMessageRequested -> "${event.content}"');
    repository.sendWsTextMessage(event.content);

    // Optimistically add message so UI updates instantaneously like WhatsApp!
    if (state is ChatLoadedState) {
      final current = state as ChatLoadedState;
      final tempMessage = ChatMessageEntity(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        groupId: '',
        senderId: 'me',
        messageType: 'text',
        content: event.content,
        createdAt: DateTime.now(),
      );
      final updated = List<ChatMessageEntity>.from(current.messages)..add(tempMessage);
      emit(current.copyWith(messages: updated));
    }
  }

  Future<void> _onChatSendImageMessageRequested(
    ChatSendImageMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    debugPrint('[CHAT_BLOC] 📷 Event: ChatSendImageMessageRequested -> imageUrl: ${event.imageUrl}');

    try {
      final msg = await sendImageMessageUseCase(
        tripId: event.tripId,
        imageUrl: event.imageUrl,
        fileName: event.fileName,
      );

      repository.sendWsImageMessage(
        imageUrl: event.imageUrl,
        fileName: event.fileName,
      );

      debugPrint('[CHAT_BLOC] ✅ Image message confirmed! ID: ${msg.id}');
      if (state is ChatLoadedState) {
        final current = state as ChatLoadedState;
        final updated = List<ChatMessageEntity>.from(current.messages)..add(msg);
        emit(current.copyWith(messages: updated));
      }
    } on ServerException catch (e) {
      debugPrint('[CHAT_BLOC] ❌ Image Message Error: ${e.message}');
      emit(ChatErrorState(message: e.message));
    } catch (e) {
      debugPrint('[CHAT_BLOC] 💥 Unexpected Image Message Error: $e');
      emit(ChatErrorState(message: 'Failed to send image message: ${e.toString()}'));
    }
  }

  void _onChatDisconnectWebSocketRequested(
    ChatDisconnectWebSocketRequested event,
    Emitter<ChatState> emit,
  ) {
    debugPrint('[CHAT_BLOC] 🔌 Event: ChatDisconnectWebSocketRequested');
    _wsSubscription?.cancel();
    repository.disconnectWebSocket();
    if (state is ChatLoadedState) {
      emit((state as ChatLoadedState).copyWith(isWsConnected: false));
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    repository.disconnectWebSocket();
    return super.close();
  }
}
