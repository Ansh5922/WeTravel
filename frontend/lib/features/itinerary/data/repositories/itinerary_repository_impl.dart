import '../../domain/entities/itinerary_entity.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../datasources/itinerary_remote_data_source.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryRemoteDataSource remoteDataSource;

  ItineraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ItineraryEntity>> getItineraries(String tripId) {
    return remoteDataSource.getItineraries(tripId);
  }

  @override
  Future<ItineraryEntity> getItineraryById(String tripId, String itineraryId) {
    return remoteDataSource.getItineraryById(tripId, itineraryId);
  }

  @override
  Future<List<ItineraryEntity>> generateItineraries({
    required String tripId,
    required String origin,
    required String destination,
    required String startDate,
    required String endDate,
    int? memberCount,
    Map<String, dynamic>? constraints,
  }) {
    return remoteDataSource.generateItineraries(
      tripId: tripId,
      origin: origin,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      memberCount: memberCount,
      constraints: constraints,
    );
  }

  @override
  Future<ItineraryEntity> selectItinerary(String tripId, String itineraryId) {
    return remoteDataSource.selectItinerary(tripId, itineraryId);
  }
}
