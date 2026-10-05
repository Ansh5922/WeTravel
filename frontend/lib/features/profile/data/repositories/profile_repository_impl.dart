import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getProfile(String token) async {
    try {
      return await remoteDataSource.getProfile(token);
    } catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<({ProfileEntity profile, UserEntity? user, String message})> updateProfile({
    required String token,
    String? fullName,
    String? phone,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
  }) async {
    try {
      return await remoteDataSource.updateProfile(
        token: token,
        fullName: fullName,
        phone: phone,
        travelStyle: travelStyle,
        dietaryPreference: dietaryPreference,
        budget: budget,
        budgetTier: budgetTier,
        pacePreference: pacePreference,
        rawPreferenceNotes: rawPreferenceNotes,
      );
    } catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  Failure _mapExceptionToFailure(Object e) {
    if (e is AuthException) {
      return AuthFailure(e.message, e.statusCode);
    } else if (e is ServerException) {
      return ServerFailure(e.message, e.statusCode);
    } else if (e is NetworkException) {
      return NetworkFailure(e.message);
    } else if (e is DioException) {
      final response = e.response;
      final statusCode = response?.statusCode;
      String message = e.message ?? 'An unexpected network error occurred.';

      dynamic data = response?.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic> && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const NetworkFailure(
          'Unable to connect to the server. Please check your internet connection.',
        );
      }

      if (statusCode == 400 || statusCode == 401 || statusCode == 409) {
        return AuthFailure(message, statusCode);
      }
      return ServerFailure(message, statusCode);
    } else if (e is Failure) {
      return e;
    }

    return ServerFailure(e.toString());
  }
}
