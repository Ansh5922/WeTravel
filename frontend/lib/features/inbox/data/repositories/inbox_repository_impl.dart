import '../../domain/entities/inbox_invite_entity.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../datasources/inbox_remote_data_source.dart';

class InboxRepositoryImpl implements InboxRepository {
  final InboxRemoteDataSource remoteDataSource;

  InboxRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InboxInviteEntity>> getMyInvites() async {
    return remoteDataSource.getMyInvites();
  }

  @override
  Future<String> respondToInvite({
    required String inviteId,
    required String action,
  }) async {
    return remoteDataSource.respondToInvite(inviteId: inviteId, action: action);
  }
}
