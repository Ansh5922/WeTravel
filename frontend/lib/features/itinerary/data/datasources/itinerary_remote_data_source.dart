import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/itinerary_model.dart';

abstract class ItineraryRemoteDataSource {
  Future<List<ItineraryModel>> getItineraries(String tripId);
  Future<ItineraryModel> getItineraryById(String tripId, String itineraryId);
  Future<List<ItineraryModel>> generateItineraries({
    required String tripId,
    required String origin,
    required String destination,
    required String startDate,
    required String endDate,
    int? memberCount,
    Map<String, dynamic>? constraints,
  });
  Future<ItineraryModel> selectItinerary(String tripId, String itineraryId);
}

class ItineraryRemoteDataSourceImpl implements ItineraryRemoteDataSource {
  final Dio dio;

  ItineraryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItineraryModel>> getItineraries(String tripId) async {
    final endpoint = '${ApiConstants.trips}/$tripId/itineraries';
    debugPrint('[ITINERARY_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[ITINERARY_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[ITINERARY_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as Map<String, dynamic>?)?['itineraries'] as List<dynamic>? ?? [];

      return list
          .map((item) => ItineraryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] ❌ DioError on getItineraries: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch itineraries.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] 💥 Unexpected Error on getItineraries: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ItineraryModel> getItineraryById(String tripId, String itineraryId) async {
    final endpoint = '${ApiConstants.trips}/$tripId/itineraries/$itineraryId';
    debugPrint('[ITINERARY_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[ITINERARY_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[ITINERARY_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final itinJson = (data['data'] as Map<String, dynamic>?)?['itinerary'] as Map<String, dynamic>? ?? data;

      return ItineraryModel.fromJson(itinJson);
    } on DioException catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] ❌ DioError on getItineraryById: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch itinerary details.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] 💥 Unexpected Error on getItineraryById: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ItineraryModel>> generateItineraries({
    required String tripId,
    required String origin,
    required String destination,
    required String startDate,
    required String endDate,
    int? memberCount,
    Map<String, dynamic>? constraints,
  }) async {
    final endpoint = '${ApiConstants.trips}/$tripId/itinerary/generate';
    final payload = {
      'origin': origin,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      if (memberCount != null) 'memberCount': memberCount,
      if (constraints != null) 'constraints': constraints,
    };

    debugPrint('[ITINERARY_REMOTE_DS] 🤖 🚀 POST $endpoint Payload: $payload');

    try {
      final response = await dio.post(endpoint, data: payload);
      debugPrint('[ITINERARY_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[ITINERARY_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as Map<String, dynamic>?)?['itineraries'] as List<dynamic>? ?? [];

      return list
          .map((item) => ItineraryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] ❌ DioError on generateItineraries: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to generate itineraries via AI.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] 💥 Unexpected Error on generateItineraries: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ItineraryModel> selectItinerary(String tripId, String itineraryId) async {
    final endpoint = '${ApiConstants.trips}/$tripId/itineraries/$itineraryId/select';
    debugPrint('[ITINERARY_REMOTE_DS] 🚀 PATCH $endpoint');

    try {
      final response = await dio.patch(endpoint);
      debugPrint('[ITINERARY_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[ITINERARY_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final itinJson = (data['data'] as Map<String, dynamic>?)?['itinerary'] as Map<String, dynamic>? ?? data;

      return ItineraryModel.fromJson(itinJson);
    } on DioException catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] ❌ DioError on selectItinerary: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to select itinerary.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[ITINERARY_REMOTE_DS] 💥 Unexpected Error on selectItinerary: $e');
      throw ServerException(e.toString());
    }
  }
}
