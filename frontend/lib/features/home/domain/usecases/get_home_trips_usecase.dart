import '../entities/home_trip.dart';
import '../repositories/home_repository.dart';

class GetHomeTripsUseCase {
  final HomeRepository repository;

  GetHomeTripsUseCase(this.repository);

  Future<List<HomeTripEntity>> call({String? status}) {
    return repository.getHomeTrips(status: status);
  }
}
