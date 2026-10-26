import '../repositories/trip_repository.dart';

class InviteTripMemberUseCase {
  final TripRepository repository;

  InviteTripMemberUseCase(this.repository);

  Future<({String message, String? inviteToken, String? joinUrl})> call({
    required String tripId,
    required String type,
    String? friendId,
    String? username,
    String? email,
    String? phone,
  }) {
    return repository.inviteMember(
      tripId: tripId,
      type: type,
      friendId: friendId,
      username: username,
      email: email,
      phone: phone,
    );
  }
}
