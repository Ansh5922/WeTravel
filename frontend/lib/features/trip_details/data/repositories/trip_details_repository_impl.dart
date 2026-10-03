import '../../domain/repositories/trip_details_repository.dart';
import '../datasources/trip_details_remote_data_source.dart';

class TripDetailsRepositoryImpl implements TripDetailsRepository {
  final TripDetailsRemoteDataSource remoteDataSource;

  TripDetailsRepositoryImpl({required this.remoteDataSource});
}
