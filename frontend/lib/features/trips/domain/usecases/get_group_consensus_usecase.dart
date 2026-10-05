import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetGroupConsensusUseCase {
  final TripRepository repository;

  GetGroupConsensusUseCase(this.repository);

  Future<GroupConsensusEntity> call(String tripId) {
    return repository.getGroupConsensus(tripId);
  }
}
