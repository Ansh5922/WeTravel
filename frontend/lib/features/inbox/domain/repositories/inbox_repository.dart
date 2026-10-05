import '../entities/inbox_invite_entity.dart';

abstract class InboxRepository {
  /// Fetch all pending direct invitations for the current user.
  Future<List<InboxInviteEntity>> getMyInvites();

  /// Accept or reject a trip invitation.
  /// [action] must be 'accept' or 'reject'.
  Future<String> respondToInvite({
    required String inviteId,
    required String action,
  });
}
