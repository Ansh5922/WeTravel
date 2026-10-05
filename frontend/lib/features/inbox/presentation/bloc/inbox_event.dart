import 'package:equatable/equatable.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object?> get props => [];
}

class InboxFetchRequested extends InboxEvent {}

class InboxInviteAccepted extends InboxEvent {
  final String inviteId;

  const InboxInviteAccepted(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class InboxInviteDeclined extends InboxEvent {
  final String inviteId;

  const InboxInviteDeclined(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class InboxFilterTabChanged extends InboxEvent {
  final String tab; // 'all', 'pending', 'accepted', 'declined'

  const InboxFilterTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class InboxSearchQueryChanged extends InboxEvent {
  final String query;

  const InboxSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
