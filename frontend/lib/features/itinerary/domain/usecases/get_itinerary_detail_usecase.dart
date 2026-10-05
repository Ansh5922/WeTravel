import '../entities/itinerary_entity.dart';
import '../repositories/itinerary_repository.dart';

class GetItineraryDetailUseCase {
  final ItineraryRepository repository;

  GetItineraryDetailUseCase(this.repository);

  Future<ItineraryEntity> call(String tripId, String itineraryId) {
    return repository.getItineraryById(tripId, itineraryId);
  }
}
