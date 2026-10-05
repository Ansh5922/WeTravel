import '../entities/home_trip.dart';

abstract class HomeRepository {
  /// Fetches trips for the authenticated user with an optional status filter.
  Future<List<HomeTripEntity>> getHomeTrips({String? status});
}
