import 'package:equatable/equatable.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}

class FriendsFetchRequested extends FriendEvent {
  const FriendsFetchRequested();
}

class FriendRequestsFetchRequested extends FriendEvent {
  const FriendRequestsFetchRequested();
}

class FriendSendRequestRequested extends FriendEvent {
  final String username;
  const FriendSendRequestRequested(this.username);

  @override
  List<Object?> get props => [username];
}

class FriendRespondRequestRequested extends FriendEvent {
  final String friendshipId;
  final String action; // 'accept' | 'reject'

  const FriendRespondRequestRequested({
    required this.friendshipId,
    required this.action,
  });

  @override
  List<Object?> get props => [friendshipId, action];
}
