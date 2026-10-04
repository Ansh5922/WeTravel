import '../../domain/repositories/polls_repository.dart';
import '../datasources/polls_remote_data_source.dart';

class PollsRepositoryImpl implements PollsRepository {
  final PollsRemoteDataSource remoteDataSource;

  PollsRepositoryImpl({required this.remoteDataSource});
}
