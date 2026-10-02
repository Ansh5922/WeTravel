import '../../domain/repositories/group_chat_repository.dart';
import '../datasources/group_chat_remote_data_source.dart';

class GroupChatRepositoryImpl implements GroupChatRepository {
  final GroupChatRemoteDataSource remoteDataSource;

  GroupChatRepositoryImpl({required this.remoteDataSource});
}
