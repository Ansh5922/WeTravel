import '../../domain/repositories/trips_repository.dart';
import '../datasources/trips_remote_data_source.dart';

class TripsRepositoryImpl implements TripsRepository {
  final TripsRemoteDataSource remoteDataSource;

  TripsRepositoryImpl({required this.remoteDataSource});
}
