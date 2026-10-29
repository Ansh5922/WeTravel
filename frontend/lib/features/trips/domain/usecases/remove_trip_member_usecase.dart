import '../repositories/trip_repository.dart';

class RemoveTripMemberUseCase {
  final TripRepository repository;

  RemoveTripMemberUseCase(this.repository);

  Future<void> call({
    required String tripId,
    required String userId,
  }) {
    return repository.removeMember(tripId: tripId, userId: userId);
  }
}

