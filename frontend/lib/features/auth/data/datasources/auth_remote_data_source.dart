import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> signup({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? phone,
  });

  Future<AuthResponseModel> googleLogin({
    required String idToken,
  });

  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> googleLogin({
    required String idToken,
  }) async {
    debugPrint('[AUTH_REMOTE_DS] 🚀 POST ${ApiConstants.googleSignIn}');
    try {
      final response = await dio.post(
        ApiConstants.googleSignIn,
        data: {
          'idToken': idToken,
        },
      );

      debugPrint('[AUTH_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
      debugPrint('[AUTH_REMOTE_DS] 📦 Data: ${response.data}');

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(data);
      } else {
        throw const ServerException('Invalid response format from server.');
      }
    } on DioException catch (e) {
      debugPrint('[AUTH_REMOTE_DS] ❌ DioError on Google Login: [${e.response?.statusCode}] ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[AUTH_REMOTE_DS] 💥 Error on Google Login: $e');
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[AUTH_REMOTE_DS] 🚀 POST ${ApiConstants.login} -> Email: $email');
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      debugPrint('[AUTH_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
      debugPrint('[AUTH_REMOTE_DS] 📦 Data: ${response.data}');

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(data);
      } else {
        throw const ServerException('Invalid response format from server.');
      }
    } on DioException catch (e) {
      debugPrint('[AUTH_REMOTE_DS] ❌ DioError on Login: [${e.response?.statusCode}] ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[AUTH_REMOTE_DS] 💥 Error on Login: $e');
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> signup({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? phone,
  }) async {
    debugPrint('[AUTH_REMOTE_DS] 🚀 POST ${ApiConstants.signup} -> Email: $email, Username: $username');
    try {
      final response = await dio.post(
        ApiConstants.signup,
        data: {
          'email': email,
          'password': password,
          'username': username,
          if (fullName != null && fullName.trim().isNotEmpty)
            'fullName': fullName.trim(),
          if (phone != null && phone.trim().isNotEmpty)
            'phone': phone.trim(),
        },
      );

      debugPrint('[AUTH_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
      debugPrint('[AUTH_REMOTE_DS] 📦 Data: ${response.data}');

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(data);
      } else {
        throw const ServerException('Invalid response format from server.');
      }
    } on DioException catch (e) {
      debugPrint('[AUTH_REMOTE_DS] ❌ DioError on Signup: [${e.response?.statusCode}] ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[AUTH_REMOTE_DS] 💥 Error on Signup: $e');
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    debugPrint('[AUTH_REMOTE_DS] 🚀 GET ${ApiConstants.me}');
    try {
      final response = await dio.get(
        ApiConstants.me,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('[AUTH_REMOTE_DS] ✅ Response Code: ${response.statusCode}');
      debugPrint('[AUTH_REMOTE_DS] 📦 Data: ${response.data}');

      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        final authResponse = AuthResponseModel.fromJson(data);
        return authResponse.user as UserModel;
      } else {
        throw const ServerException('Invalid response format from server.');
      }
    } on DioException catch (e) {
      debugPrint('[AUTH_REMOTE_DS] ❌ DioError on GetCurrentUser: [${e.response?.statusCode}] ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      debugPrint('[AUTH_REMOTE_DS] 💥 Error on GetCurrentUser: $e');
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
