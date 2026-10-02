import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_remote_data_source.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource remoteDataSource;

  SplashRepositoryImpl({required this.remoteDataSource});
}
