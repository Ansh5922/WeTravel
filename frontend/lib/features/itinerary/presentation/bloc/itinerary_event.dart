import 'package:equatable/equatable.dart';

abstract class ItineraryEvent extends Equatable {
  const ItineraryEvent();

  @override
  List<Object?> get props => [];
}

class ItinerariesFetchRequested extends ItineraryEvent {
  final String tripId;

  const ItinerariesFetchRequested(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class ItineraryDetailRequested extends ItineraryEvent {
  final String tripId;
  final String itineraryId;

  const ItineraryDetailRequested({
    required this.tripId,
    required this.itineraryId,
  });

  @override
  List<Object?> get props => [tripId, itineraryId];
}

class ItineraryGenerateRequested extends ItineraryEvent {
  final String tripId;
  final String origin;
  final String destination;
  final String startDate;
  final String endDate;
  final int? memberCount;
  final Map<String, dynamic>? constraints;

  const ItineraryGenerateRequested({
    required this.tripId,
    required this.origin,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.memberCount,
    this.constraints,
  });

  @override
  List<Object?> get props => [
        tripId,
        origin,
        destination,
        startDate,
        endDate,
        memberCount,
        constraints,
      ];
}

class ItinerarySelectRequested extends ItineraryEvent {
  final String tripId;
  final String itineraryId;

  const ItinerarySelectRequested({
    required this.tripId,
    required this.itineraryId,
  });

  @override
  List<Object?> get props => [tripId, itineraryId];
}
