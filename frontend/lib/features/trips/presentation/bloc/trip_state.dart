import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitialState extends TripState {}

class TripLoadingState extends TripState {}

class MyTripsLoadedState extends TripState {
  final List<TripEntity> trips;

  const MyTripsLoadedState({required this.trips});

  @override
  List<Object?> get props => [trips];
}

class TripDetailLoadedState extends TripState {
  final TripEntity trip;
  final GroupConsensusEntity? consensus;

  const TripDetailLoadedState({
    required this.trip,
    this.consensus,
  });

  @override
  List<Object?> get props => [trip, consensus];
}

class TripCreatedState extends TripState {
  final TripEntity trip;
  final String message;

  const TripCreatedState({
    required this.trip,
    required this.message,
  });

  @override
  List<Object?> get props => [trip, message];
}

class TripInviteSentState extends TripState {
  final String message;
  final String? inviteToken;
  final String? joinUrl;

  const TripInviteSentState({
    required this.message,
    this.inviteToken,
    this.joinUrl,
  });

  @override
  List<Object?> get props => [message, inviteToken, joinUrl];
}

class TripJoinedState extends TripState {
  final TripEntity trip;

  const TripJoinedState({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripErrorState extends TripState {
  final String message;

  const TripErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
