import '../repositories/trip_repository.dart';

class InviteTripMemberUseCase {
  final TripRepository repository;

  InviteTripMemberUseCase(this.repository);

  Future<({String message, String? inviteToken, String? joinUrl})> call({
    required String tripId,
    required String type,
    String? friendId,
    String? email,
    String? phone,
  }) {
    return repository.inviteMember(
      tripId: tripId,
      type: type,
      friendId: friendId,
      email: email,
      phone: phone,
    );
  }
}
