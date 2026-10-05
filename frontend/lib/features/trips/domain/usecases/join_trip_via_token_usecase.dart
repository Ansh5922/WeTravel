import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class JoinTripViaTokenUseCase {
  final TripRepository repository;

  JoinTripViaTokenUseCase(this.repository);

  Future<TripEntity> call(String token) {
    return repository.joinViaToken(token);
  }
}
