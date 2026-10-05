import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class CreateTripUseCase {
  final TripRepository repository;

  CreateTripUseCase(this.repository);

  Future<TripEntity> call({
    required String name,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? coverImageUrl,
  }) {
    return repository.createTrip(
      name: name,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      coverImageUrl: coverImageUrl,
    );
  }
}
