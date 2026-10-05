import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<ChatMessageEntity> messages;
  final bool isWsConnected;
  final String? error;

  const ChatLoadedState({
    required this.messages,
    this.isWsConnected = false,
    this.error,
  });

  ChatLoadedState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isWsConnected,
    String? error,
  }) {
    return ChatLoadedState(
      messages: messages ?? this.messages,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isWsConnected, error];
}

class ChatErrorState extends ChatState {
  final String message;
  const ChatErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
