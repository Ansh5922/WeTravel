import '../entities/inbox_invite_entity.dart';
import '../repositories/inbox_repository.dart';

class GetMyInvitesUseCase {
  final InboxRepository repository;

  GetMyInvitesUseCase(this.repository);

  Future<List<InboxInviteEntity>> call() {
    return repository.getMyInvites();
  }
}
