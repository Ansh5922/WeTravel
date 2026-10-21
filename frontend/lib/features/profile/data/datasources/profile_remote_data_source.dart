import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<({ProfileModel profile, UserModel? user})> getProfile(String token);

  Future<({ProfileModel profile, UserModel? user, String message})> updateProfile({
    required String token,
    String? fullName,
    String? username,
    String? phone,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    Map<String, dynamic>? healthConstraints,
    Map<String, dynamic>? climateSensitivities,
    String? rawPreferenceNotes,
  });

  Future<void> deleteAccount(String token);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<({ProfileModel profile, UserModel? user})> getProfile(String token) async {
    debugPrint('[PROFILE_REMOTE_DS] 🚀 GET ${ApiConstants.userProfile}');
    try {
      final response = await dio.get(
        ApiConstants.userProfile,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('[PROFILE_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
      debugPrint('[PROFILE_REMOTE_DS] 📦 Data: ${response.data}');

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        final resData = (data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : data;

        final profileJson = resData['profile'] is Map<String, dynamic>
            ? resData['profile'] as Map<String, dynamic>
            : resData;
        final profile = ProfileModel.fromJson(profileJson);

        UserModel? user;
        if (resData['user'] is Map<String, dynamic>) {
          user = UserModel.fromJson(resData['user'] as Map<String, dynamic>);
        }

        return (profile: profile, user: user);
      } else {
        throw const ServerException('Invalid response format from server.');
      }
    } on DioException catch (e) {
      debugPrint('[PROFILE_REMOTE_DS] ❌ DioError on getProfile: [${e.response?.statusCode}] ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[PROFILE_REMOTE_DS] 💥 Error on getProfile: $e');
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<({ProfileModel profile, UserModel? user, String message})> updateProfile({
    required String token,
    String? fullName,
    String? username,
    String? phone,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    Map<String, dynamic>? healthConstraints,
    Map<String, dynamic>? climateSensitivities,
    String? rawPreferenceNotes,
  }) async {
    final payload = <String, dynamic>{
      if (fullName != null && fullName.trim().isNotEmpty) 'fullName': fullName.trim(),
      if (username != null && username.trim().isNotEmpty) 'username': username.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (travelStyle != null && travelStyle.trim().isNotEmpty) 'travelStyle': travelStyle.trim(),
      if (dietaryPreference != null && dietaryPreference.trim().isNotEmpty) 'dietaryPreference': dietaryPreference.trim(),
      if (budget != null) ...{'budget': budget},
      if (budgetTier != null && budgetTier.trim().isNotEmpty) 'budgetTier': budgetTier.trim(),
      if (pacePreference != null && pacePreference.trim().isNotEmpty) 'pacePreference': pacePreference.trim(),
      if (healthConstraints != null) 'healthConstraints': healthConstraints,
      if (climateSensitivities != null) 'climateSensitivities': climateSensitivities,
      if (rawPreferenceNotes != null && rawPreferenceNotes.trim().isNotEmpty) 'rawPreferenceNotes': rawPreferenceNotes.trim(),
    };

    debugPrint('[PROFILE_REMOTE_DS] 🚀 PATCH ${ApiConstants.userProfile} Payload: $payload');

    try {
      final response = await dio.patch(
        ApiConstants.userProfile,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('[PROFILE_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
      debugPrint('[PROFILE_REMOTE_DS] 📦 Data: ${response.data}');

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString() ?? 'Profile updated successfully.';
        final resData = (data['data'] is Map<String, dynamic>)
            ? data['data'] as Map<String, dynamic>
            : data;

        final profileJson = resData['profile'] is Map<String, dynamic>
            ? resData['profile'] as Map<String, dynamic>
            : resData;
        final profile = ProfileModel.fromJson(profileJson);

        UserModel? user;
        if (resData['user'] is Map<String, dynamic>) {
          user = UserModel.fromJson(resData['user'] as Map<String, dynamic>);
        }

        return (profile: profile, user: user, message: message);
      } else {
        throw const ServerException('Invalid response format from server.');
      }
    } on DioException catch (e) {
      debugPrint('[PROFILE_REMOTE_DS] ❌ DioError on updateProfile: [${e.response?.statusCode}] ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[PROFILE_REMOTE_DS] 💥 Error on updateProfile: $e');
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount(String token) async {
    debugPrint('[PROFILE_REMOTE_DS] 🚀 DELETE ${ApiConstants.deleteAccount}');
    try {
      final response = await dio.delete(
        ApiConstants.deleteAccount,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      debugPrint('[PROFILE_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PROFILE_REMOTE_DS] ⚠️ DioError on deleteAccount: [${e.response?.statusCode}] ${e.message}');
      // If backend route is not yet implemented by teammate (404/501), allow frontend to proceed
      if (e.response?.statusCode == 404 || e.response?.statusCode == 501) {
        debugPrint('[PROFILE_REMOTE_DS] ℹ️ Backend delete endpoint will be implemented later by teammate. Proceeding with client session clearance.');
        return;
      }
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[PROFILE_REMOTE_DS] 💥 Error on deleteAccount: $e');
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'Unable to connect to the server. Please check your internet connection.',
      );
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      String message = 'An unexpected error occurred.';

      dynamic data = response.data;
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

      if (statusCode == 400 || statusCode == 401 || statusCode == 409) {
        return AuthException(message, statusCode);
      }

      return ServerException(message, statusCode);
    }

    return ServerException(error.message ?? 'An unexpected error occurred.');
  }
}
