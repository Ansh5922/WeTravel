import '../entities/itinerary_entity.dart';
import '../repositories/itinerary_repository.dart';

class GenerateItineraryUseCase {
  final ItineraryRepository repository;

  GenerateItineraryUseCase(this.repository);

  Future<List<ItineraryEntity>> call({
    required String tripId,
    required String origin,
    required String destination,
    required String startDate,
    required String endDate,
    int? memberCount,
    Map<String, dynamic>? constraints,
  }) {
    return repository.generateItineraries(
      tripId: tripId,
      origin: origin,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      memberCount: memberCount,
      constraints: constraints,
    );
  }
}
