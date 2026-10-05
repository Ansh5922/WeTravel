import '../entities/trip_entity.dart';

abstract class TripRepository {
  Future<TripEntity> createTrip({
    required String name,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? coverImageUrl,
  });

  Future<List<TripEntity>> getMyTrips({String? status});

  Future<TripEntity> getTripDetails(String tripId);

  Future<({String message, String? inviteToken, String? joinUrl})> inviteMember({
    required String tripId,
    required String type, // 'friend', 'email', 'whatsapp', 'link'
    String? friendId,
    String? email,
    String? phone,
  });

  Future<TripEntity> joinViaToken(String token);

  Future<GroupConsensusEntity> getGroupConsensus(String tripId);
}
