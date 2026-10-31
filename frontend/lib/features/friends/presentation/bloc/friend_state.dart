import 'package:equatable/equatable.dart';
import '../../domain/entities/friend_entity.dart';

abstract class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object?> get props => [];
}

class FriendInitialState extends FriendState {}

class FriendLoadingState extends FriendState {}

class FriendsLoadedState extends FriendState {
  final List<FriendEntity> friends;
  final List<FriendRequestEntity> pendingRequests;
  final List<SentFriendRequestEntity> sentRequests;
  final String? successMessage;

  const FriendsLoadedState({
    required this.friends,
    this.pendingRequests = const [],
    this.sentRequests = const [],
    this.successMessage,
  });

  FriendsLoadedState copyWith({
    List<FriendEntity>? friends,
    List<FriendRequestEntity>? pendingRequests,
    List<SentFriendRequestEntity>? sentRequests,
    String? successMessage,
  }) {
    return FriendsLoadedState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [friends, pendingRequests, sentRequests, successMessage];
}

class FriendErrorState extends FriendState {
  final String message;
  const FriendErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
