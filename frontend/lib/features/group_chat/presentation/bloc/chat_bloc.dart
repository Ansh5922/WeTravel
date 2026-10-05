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
        if (state is ChatLoadedState) {
          final current = state as ChatLoadedState;
          final updated = List<ChatMessageEntity>.from(current.messages)..add(newMsg);
          emit(current.copyWith(messages: updated, isWsConnected: true));
        }
      },
      onError: (err) {
        debugPrint('[CHAT_BLOC] ❌ WS Stream error: $err');
        if (state is ChatLoadedState) {
          emit((state as ChatLoadedState).copyWith(isWsConnected: false, error: err.toString()));
        }
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
