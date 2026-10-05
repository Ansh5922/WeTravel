import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TripEntity> createTrip({
    required String name,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? coverImageUrl,
  }) {
    return remoteDataSource.createTrip(
      name: name,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      coverImageUrl: coverImageUrl,
    );
  }

  @override
  Future<List<TripEntity>> getMyTrips({String? status}) {
    return remoteDataSource.getMyTrips(status: status);
  }

  @override
  Future<TripEntity> getTripDetails(String tripId) {
    return remoteDataSource.getTripDetails(tripId);
  }

  @override
  Future<({String message, String? inviteToken, String? joinUrl})> inviteMember({
    required String tripId,
    required String type,
    String? friendId,
    String? email,
    String? phone,
  }) {
    return remoteDataSource.inviteMember(
      tripId: tripId,
      type: type,
      friendId: friendId,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<TripEntity> joinViaToken(String token) {
    return remoteDataSource.joinViaToken(token);
  }

  @override
  Future<GroupConsensusEntity> getGroupConsensus(String tripId) {
    return remoteDataSource.getGroupConsensus(tripId);
  }
}
