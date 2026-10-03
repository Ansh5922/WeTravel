import '../../domain/repositories/itinerary_repository.dart';
import '../datasources/itinerary_remote_data_source.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryRemoteDataSource remoteDataSource;

  ItineraryRepositoryImpl({required this.remoteDataSource});
}
