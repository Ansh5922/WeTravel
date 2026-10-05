import '../../domain/entities/home_trip.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HomeTripEntity>> getHomeTrips({String? status}) async {
    return remoteDataSource.getHomeTrips(status: status);
  }
}
