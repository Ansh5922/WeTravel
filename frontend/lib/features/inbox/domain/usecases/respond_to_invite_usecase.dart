import '../repositories/inbox_repository.dart';

class RespondToInviteUseCase {
  final InboxRepository repository;

  RespondToInviteUseCase(this.repository);

  Future<String> call({
    required String inviteId,
    required String action,
  }) {
    return repository.respondToInvite(inviteId: inviteId, action: action);
  }
}
