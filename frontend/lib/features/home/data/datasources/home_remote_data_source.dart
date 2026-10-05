import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/home_trip_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeTripModel>> getHomeTrips({String? status});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HomeTripModel>> getHomeTrips({String? status}) async {
    final endpoint = ApiConstants.trips;
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }

    debugPrint('[HOME_REMOTE_DS] 🚀 GET $endpoint Params: $queryParams');

    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      debugPrint('[HOME_REMOTE_DS] ✅ Response Status: ${response.statusCode}');
      debugPrint('[HOME_REMOTE_DS] 📦 Response Data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final tripsData = (data['data'] as Map<String, dynamic>?)?['trips'] as List<dynamic>? ?? [];

      return tripsData
          .map((json) => HomeTripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[HOME_REMOTE_DS] ❌ DioError: [${e.response?.statusCode}] ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to fetch home trips. Please try again.';
      throw ServerException(errorMessage, e.response?.statusCode);
    } catch (e) {
      debugPrint('[HOME_REMOTE_DS] 💥 Unexpected Error: $e');
      throw ServerException(e.toString());
    }
  }
}
