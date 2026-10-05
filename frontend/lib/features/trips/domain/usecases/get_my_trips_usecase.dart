import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetMyTripsUseCase {
  final TripRepository repository;

  GetMyTripsUseCase(this.repository);

  Future<List<TripEntity>> call({String? status}) {
    return repository.getMyTrips(status: status);
  }
}
