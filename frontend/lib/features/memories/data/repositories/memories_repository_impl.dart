import '../../domain/repositories/memories_repository.dart';
import '../datasources/memories_remote_data_source.dart';

class MemoriesRepositoryImpl implements MemoriesRepository {
  final MemoriesRemoteDataSource remoteDataSource;

  MemoriesRepositoryImpl({required this.remoteDataSource});
}
