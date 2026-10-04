import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.login(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<AuthResponseEntity> signup({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? phone,
  }) async {
    try {
      return await remoteDataSource.signup(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phone: phone,
      );
    } catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<AuthResponseEntity> googleLogin({
    required String idToken,
  }) async {
    try {
      return await remoteDataSource.googleLogin(idToken: idToken);
    } catch (e) {
      throw _mapExceptionToFailure(e);
    }
  }

  @override
  Future<UserEntity> getCurrentUser(String token) async {
    try {
      return await remoteDataSource.getCurrentUser(token);
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
