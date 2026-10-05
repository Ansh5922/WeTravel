import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/google_signin_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

/// Centralized Factory for creating Clean Architecture layers and BLoC instances.
class ServiceLocator {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.backendBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('--------------------------------------------------');
          debugPrint('📡 [DIO REQ] ${options.method} ${options.baseUrl}${options.path}');
          if (options.headers.isNotEmpty) {
            debugPrint('🔑 Headers: ${options.headers}');
          }
          if (options.data != null) {
            debugPrint('📤 Body: ${options.data}');
          }
          debugPrint('--------------------------------------------------');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('--------------------------------------------------');
          debugPrint('📥 [DIO RES] ${response.statusCode} ${response.requestOptions.path}');
          debugPrint('📦 Payload: ${response.data}');
          debugPrint('--------------------------------------------------');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('--------------------------------------------------');
          debugPrint('❌ [DIO ERR] ${e.response?.statusCode ?? 'NETWORK'} ${e.requestOptions.path}');
          debugPrint('💥 Message: ${e.message}');
          if (e.response?.data != null) {
            debugPrint('📦 Response Data: ${e.response?.data}');
          }
          debugPrint('--------------------------------------------------');
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  // ── Auth Singletons ─────────────────────────────────────────────────────────
  static final AuthLocalDataSource authLocalDataSource =
      AuthLocalDataSourceImpl(storage: _storage);

  static final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSourceImpl(dio: _dio);

  static final AuthRepository authRepository =
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  static final LoginUseCase loginUseCase = LoginUseCase(authRepository);
  static final SignupUseCase signupUseCase = SignupUseCase(authRepository);
  static final GoogleSignInUseCase googleSignInUseCase =
      GoogleSignInUseCase(authRepository);
  static final GetCurrentUserUseCase getCurrentUserUseCase =
      GetCurrentUserUseCase(authRepository);

  // ── Profile Singletons ──────────────────────────────────────────────────────
  static final ProfileRemoteDataSource profileRemoteDataSource =
      ProfileRemoteDataSourceImpl(dio: _dio);

  static final ProfileRepository profileRepository =
      ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);

  static final GetProfileUseCase getProfileUseCase =
      GetProfileUseCase(profileRepository);

  static final UpdateProfileUseCase updateProfileUseCase =
      UpdateProfileUseCase(profileRepository);

  /// Factory method to create a new AuthBloc instance connected to all Auth UseCases.
  static AuthBloc createAuthBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      signupUseCase: signupUseCase,
      googleSignInUseCase: googleSignInUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      localDataSource: authLocalDataSource,
    );
  }

  /// Factory method to create a new ProfileBloc instance connected to all Profile UseCases.
  static ProfileBloc createProfileBloc() {
    return ProfileBloc(
      getProfileUseCase: getProfileUseCase,
      updateProfileUseCase: updateProfileUseCase,
    );
  }
}
