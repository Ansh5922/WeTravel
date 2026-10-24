import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatMessagesFetchRequested extends ChatEvent {
  final String tripId;
  final String? before;

  const ChatMessagesFetchRequested({required this.tripId, this.before});

  @override
  List<Object?> get props => [tripId, before];
}

class ChatConnectWebSocketRequested extends ChatEvent {
  final String tripId;
  final String token;

  const ChatConnectWebSocketRequested({required this.tripId, required this.token});

  @override
  List<Object?> get props => [tripId, token];
}

class ChatSendTextMessageRequested extends ChatEvent {
  final String content;

  const ChatSendTextMessageRequested({required this.content});

  @override
  List<Object?> get props => [content];
}

class ChatSendImageMessageRequested extends ChatEvent {
  final String tripId;
  final String imageUrl;
  final String? fileName;

  const ChatSendImageMessageRequested({
    required this.tripId,
    required this.imageUrl,
    this.fileName,
  });

  @override
  List<Object?> get props => [tripId, imageUrl, fileName];
}

class ChatDisconnectWebSocketRequested extends ChatEvent {
  const ChatDisconnectWebSocketRequested();
}

class ChatMessageReceived extends ChatEvent {
  final ChatMessageEntity message;
  const ChatMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatWsConnectionChanged extends ChatEvent {
  final bool isConnected;
  final String? error;
  const ChatWsConnectionChanged({required this.isConnected, this.error});

  @override
  List<Object?> get props => [isConnected, error];
}
