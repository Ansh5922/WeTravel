import '../entities/itinerary_entity.dart';
import '../repositories/itinerary_repository.dart';

class SelectItineraryUseCase {
  final ItineraryRepository repository;

  SelectItineraryUseCase(this.repository);

  Future<ItineraryEntity> call(String tripId, String itineraryId) {
    return repository.selectItinerary(tripId, itineraryId);
  }
}
