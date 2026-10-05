import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> createTrip({
    required String name,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? coverImageUrl,
  });

  Future<List<TripModel>> getMyTrips({String? status});

  Future<TripModel> getTripDetails(String tripId);

  Future<({String message, String? inviteToken, String? joinUrl})> inviteMember({
    required String tripId,
    required String type,
    String? friendId,
    String? email,
    String? phone,
  });

  Future<TripModel> joinViaToken(String token);

  Future<GroupConsensusModel> getGroupConsensus(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<TripModel> createTrip({
    required String name,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? coverImageUrl,
  }) async {
    const endpoint = ApiConstants.trips;
    final payload = <String, dynamic>{
      'name': name,
      if (tripStartDate != null) 'tripStartDate': tripStartDate.toIso8601String(),
      if (tripEndDate != null) 'tripEndDate': tripEndDate.toIso8601String(),
      if (coverImageUrl != null && coverImageUrl.trim().isNotEmpty) 'coverImageUrl': coverImageUrl.trim(),
    };

    debugPrint('[TRIP_REMOTE_DS] 🚀 POST $endpoint Payload: $payload');

    try {
      final response = await dio.post(endpoint, data: payload);
      debugPrint('[TRIP_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[TRIP_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final tripJson = (data['data'] as Map<String, dynamic>?)?['trip'] as Map<String, dynamic>? ?? data;

      return TripModel.fromJson(tripJson);
    } on DioException catch (e) {
      debugPrint('[TRIP_REMOTE_DS] ❌ DioError on createTrip: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to create trip.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[TRIP_REMOTE_DS] 💥 Unexpected Error on createTrip: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripModel>> getMyTrips({String? status}) async {
    const endpoint = ApiConstants.trips;
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status.toLowerCase();
    }

    debugPrint('[TRIP_REMOTE_DS] 🚀 GET $endpoint Params: $queryParams');

    try {
      final response = await dio.get(endpoint, queryParameters: queryParams);
      debugPrint('[TRIP_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[TRIP_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as Map<String, dynamic>?)?['trips'] as List<dynamic>? ?? [];

      return list
          .map((item) => TripModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[TRIP_REMOTE_DS] ❌ DioError on getMyTrips: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch user trips.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[TRIP_REMOTE_DS] 💥 Unexpected Error on getMyTrips: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> getTripDetails(String tripId) async {
    final endpoint = '${ApiConstants.trips}/$tripId';
    debugPrint('[TRIP_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[TRIP_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[TRIP_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final tripJson = (data['data'] as Map<String, dynamic>?)?['trip'] as Map<String, dynamic>? ?? data;

      return TripModel.fromJson(tripJson);
    } on DioException catch (e) {
      debugPrint('[TRIP_REMOTE_DS] ❌ DioError on getTripDetails: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch trip details.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[TRIP_REMOTE_DS] 💥 Unexpected Error on getTripDetails: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<({String message, String? inviteToken, String? joinUrl})> inviteMember({
    required String tripId,
    required String type,
    String? friendId,
    String? email,
    String? phone,
  }) async {
    final endpoint = '${ApiConstants.trips}/$tripId/invite';
    final payload = <String, dynamic>{
      'type': type,
      if (friendId != null) 'friendId': friendId,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };

    debugPrint('[TRIP_REMOTE_DS] 🚀 POST $endpoint Payload: $payload');

    try {
      final response = await dio.post(endpoint, data: payload);
      debugPrint('[TRIP_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[TRIP_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final message = data['message']?.toString() ?? 'Invite sent.';
      final resData = (data['data'] as Map<String, dynamic>?) ?? {};
      final inviteObj = (resData['invite'] as Map<String, dynamic>?) ?? {};

      return (
        message: message,
        inviteToken: inviteObj['inviteToken']?.toString(),
        joinUrl: resData['joinUrl']?.toString(),
      );
    } on DioException catch (e) {
      debugPrint('[TRIP_REMOTE_DS] ❌ DioError on inviteMember: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to send invite.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[TRIP_REMOTE_DS] 💥 Unexpected Error on inviteMember: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> joinViaToken(String token) async {
    final endpoint = '${ApiConstants.trips}/join/$token';
    debugPrint('[TRIP_REMOTE_DS] 🚀 POST $endpoint');

    try {
      final response = await dio.post(endpoint);
      debugPrint('[TRIP_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[TRIP_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final resData = (data['data'] as Map<String, dynamic>?) ?? data;
      final tripJson = (resData['trip'] as Map<String, dynamic>?) ?? resData;

      return TripModel.fromJson(tripJson);
    } on DioException catch (e) {
      debugPrint('[TRIP_REMOTE_DS] ❌ DioError on joinViaToken: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to join trip via token.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[TRIP_REMOTE_DS] 💥 Unexpected Error on joinViaToken: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GroupConsensusModel> getGroupConsensus(String tripId) async {
    final endpoint = '${ApiConstants.trips}/$tripId/consensus';
    debugPrint('[TRIP_REMOTE_DS] 🚀 GET $endpoint');

    try {
      final response = await dio.get(endpoint);
      debugPrint('[TRIP_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[TRIP_REMOTE_DS] 📦 Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final consensusJson = (data['data'] as Map<String, dynamic>?)?['consensus'] as Map<String, dynamic>? ?? data;

      return GroupConsensusModel.fromJson(consensusJson);
    } on DioException catch (e) {
      debugPrint('[TRIP_REMOTE_DS] ❌ DioError on getGroupConsensus: [${e.response?.statusCode}] ${e.message}');
      final msg = e.response?.data?['message']?.toString() ?? 'Failed to fetch group consensus.';
      throw ServerException(msg, e.response?.statusCode);
    } catch (e) {
      debugPrint('[TRIP_REMOTE_DS] 💥 Unexpected Error on getGroupConsensus: $e');
      throw ServerException(e.toString());
    }
  }
}
