import 'package:equatable/equatable.dart';
import '../../domain/entities/itinerary_entity.dart';

abstract class ItineraryState extends Equatable {
  const ItineraryState();

  @override
  List<Object?> get props => [];
}

class ItineraryInitialState extends ItineraryState {}

class ItineraryLoadingState extends ItineraryState {}

class ItinerariesLoadedState extends ItineraryState {
  final List<ItineraryEntity> itineraries;
  final ItineraryEntity? selectedItinerary;
  final String? successMessage;

  const ItinerariesLoadedState({
    required this.itineraries,
    this.selectedItinerary,
    this.successMessage,
  });

  @override
  List<Object?> get props => [itineraries, selectedItinerary, successMessage];
}

class ItineraryDetailLoadedState extends ItineraryState {
  final ItineraryEntity itinerary;

  const ItineraryDetailLoadedState({required this.itinerary});

  @override
  List<Object?> get props => [itinerary];
}

class ItineraryErrorState extends ItineraryState {
  final String message;

  const ItineraryErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
