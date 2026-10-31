import '../repositories/trip_repository.dart';

class AssignTripRoleUseCase {
  final TripRepository repository;

  AssignTripRoleUseCase(this.repository);

  Future<void> call({
    required String tripId,
    required String userId,
    required String role,
  }) async {
    return await repository.assignRole(
      tripId: tripId,
      userId: userId,
      role: role,
    );
  }
}

