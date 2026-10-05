import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class TripsFetchRequested extends TripEvent {
  final String? statusFilter;

  const TripsFetchRequested({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class TripDetailsRequested extends TripEvent {
  final String tripId;

  const TripDetailsRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class TripCreateRequested extends TripEvent {
  final String name;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? coverImageUrl;

  const TripCreateRequested({
    required this.name,
    this.tripStartDate,
    this.tripEndDate,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [name, tripStartDate, tripEndDate, coverImageUrl];
}

class TripInviteMemberRequested extends TripEvent {
  final String tripId;
  final String type; // 'friend', 'email', 'whatsapp', 'link'
  final String? friendId;
  final String? email;
  final String? phone;

  const TripInviteMemberRequested({
    required this.tripId,
    required this.type,
    this.friendId,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [tripId, type, friendId, email, phone];
}

class TripJoinViaTokenRequested extends TripEvent {
  final String token;

  const TripJoinViaTokenRequested(this.token);

  @override
  List<Object?> get props => [token];
}

class GroupConsensusRequested extends TripEvent {
  final String tripId;

  const GroupConsensusRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}
