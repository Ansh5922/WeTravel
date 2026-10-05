import '../entities/itinerary_entity.dart';

abstract class ItineraryRepository {
  Future<List<ItineraryEntity>> getItineraries(String tripId);
  Future<ItineraryEntity> getItineraryById(String tripId, String itineraryId);
  Future<List<ItineraryEntity>> generateItineraries({
    required String tripId,
    required String origin,
    required String destination,
    required String startDate,
    required String endDate,
    int? memberCount,
    Map<String, dynamic>? constraints,
  });
  Future<ItineraryEntity> selectItinerary(String tripId, String itineraryId);
}
