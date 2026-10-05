import '../entities/itinerary_entity.dart';
import '../repositories/itinerary_repository.dart';

class GetItinerariesUseCase {
  final ItineraryRepository repository;

  GetItinerariesUseCase(this.repository);

  Future<List<ItineraryEntity>> call(String tripId) {
    return repository.getItineraries(tripId);
  }
}
