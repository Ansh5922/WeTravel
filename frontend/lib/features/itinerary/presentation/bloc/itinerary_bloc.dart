import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/generate_itinerary_usecase.dart';
import '../../domain/usecases/get_itineraries_usecase.dart';
import '../../domain/usecases/get_itinerary_detail_usecase.dart';
import '../../domain/usecases/select_itinerary_usecase.dart';
import 'itinerary_event.dart';
import 'itinerary_state.dart';

class ItineraryBloc extends Bloc<ItineraryEvent, ItineraryState> {
  final GetItinerariesUseCase getItinerariesUseCase;
  final GetItineraryDetailUseCase getItineraryDetailUseCase;
  final GenerateItineraryUseCase generateItineraryUseCase;
  final SelectItineraryUseCase selectItineraryUseCase;

  ItineraryBloc({
    required this.getItinerariesUseCase,
    required this.getItineraryDetailUseCase,
    required this.generateItineraryUseCase,
    required this.selectItineraryUseCase,
  }) : super(ItineraryInitialState()) {
    on<ItinerariesFetchRequested>(_onItinerariesFetchRequested);
    on<ItineraryDetailRequested>(_onItineraryDetailRequested);
    on<ItineraryGenerateRequested>(_onItineraryGenerateRequested);
    on<ItinerarySelectRequested>(_onItinerarySelectRequested);
  }

  Future<void> _onItinerariesFetchRequested(
    ItinerariesFetchRequested event,
    Emitter<ItineraryState> emit,
  ) async {
    debugPrint('[ITINERARY_BLOC] 🗺️ Event: ItinerariesFetchRequested (tripId: ${event.tripId})');
    emit(ItineraryLoadingState());

    try {
      final list = await getItinerariesUseCase(event.tripId);
      final selected = list.where((i) => i.isSelected).firstOrNull ?? list.firstOrNull;
      debugPrint('[ITINERARY_BLOC] ✅ Fetch Success: Loaded ${list.length} itinerary variant(s)');
      emit(ItinerariesLoadedState(itineraries: list, selectedItinerary: selected));
    } on ServerException catch (e) {
      debugPrint('[ITINERARY_BLOC] ❌ Fetch Error: ${e.message}');
      emit(ItineraryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[ITINERARY_BLOC] 💥 Unexpected Error: $e');
      emit(ItineraryErrorState(message: 'Failed to fetch itineraries: ${e.toString()}'));
    }
  }

  Future<void> _onItineraryDetailRequested(
    ItineraryDetailRequested event,
    Emitter<ItineraryState> emit,
  ) async {
    debugPrint('[ITINERARY_BLOC] 🔍 Event: ItineraryDetailRequested (itineraryId: ${event.itineraryId})');
    emit(ItineraryLoadingState());

    try {
      final itinerary = await getItineraryDetailUseCase(event.tripId, event.itineraryId);
      debugPrint('[ITINERARY_BLOC] ✅ Detail Success: Version ${itinerary.version} with ${itinerary.items.length} item(s)');
      emit(ItineraryDetailLoadedState(itinerary: itinerary));
    } on ServerException catch (e) {
      debugPrint('[ITINERARY_BLOC] ❌ Detail Error: ${e.message}');
      emit(ItineraryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[ITINERARY_BLOC] 💥 Unexpected Detail Error: $e');
      emit(ItineraryErrorState(message: 'Failed to fetch itinerary detail: ${e.toString()}'));
    }
  }

  Future<void> _onItineraryGenerateRequested(
    ItineraryGenerateRequested event,
    Emitter<ItineraryState> emit,
  ) async {
    debugPrint('[ITINERARY_BLOC] 🤖 Event: ItineraryGenerateRequested -> ${event.origin} to ${event.destination} (${event.startDate} - ${event.endDate})');
    emit(ItineraryLoadingState());

    try {
      final list = await generateItineraryUseCase(
        tripId: event.tripId,
        origin: event.origin,
        destination: event.destination,
        startDate: event.startDate,
        endDate: event.endDate,
        memberCount: event.memberCount,
        constraints: event.constraints,
      );

      debugPrint('[ITINERARY_BLOC] 🎉 AI Generation Success! Created ${list.length} itinerary variant(s)');
      emit(ItinerariesLoadedState(
        itineraries: list,
        selectedItinerary: list.firstOrNull,
        successMessage: 'Generated ${list.length} personalized itineraries with AI!',
      ));
    } on ServerException catch (e) {
      debugPrint('[ITINERARY_BLOC] ❌ Generation Error: ${e.message}');
      emit(ItineraryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[ITINERARY_BLOC] 💥 Unexpected Generation Error: $e');
      emit(ItineraryErrorState(message: 'AI Generation Failed: ${e.toString()}'));
    }
  }

  Future<void> _onItinerarySelectRequested(
    ItinerarySelectRequested event,
    Emitter<ItineraryState> emit,
  ) async {
    debugPrint('[ITINERARY_BLOC] ⭐ Event: ItinerarySelectRequested (id: ${event.itineraryId})');
    emit(ItineraryLoadingState());

    try {
      final selected = await selectItineraryUseCase(event.tripId, event.itineraryId);
      final list = await getItinerariesUseCase(event.tripId);
      debugPrint('[ITINERARY_BLOC] ✅ Selection Success: Selected variant "${selected.variantType ?? selected.id}"');
      emit(ItinerariesLoadedState(
        itineraries: list,
        selectedItinerary: selected,
        successMessage: 'Itinerary selected successfully!',
      ));
    } on ServerException catch (e) {
      debugPrint('[ITINERARY_BLOC] ❌ Selection Error: ${e.message}');
      emit(ItineraryErrorState(message: e.message));
    } catch (e) {
      debugPrint('[ITINERARY_BLOC] 💥 Unexpected Selection Error: $e');
      emit(ItineraryErrorState(message: 'Failed to select itinerary: ${e.toString()}'));
    }
  }
}
