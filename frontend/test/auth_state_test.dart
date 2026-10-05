import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/domain/entities/auth_response_entity.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';

/// In-memory fake for FlutterSecureStorage to test AuthLocalDataSourceImpl
class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

/// In-memory fake implementation of AuthLocalDataSource
class FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? token;

  @override
  Future<void> saveToken(String token) async {
    this.token = token;
  }

  @override
  Future<String?> getToken() async {
    return token;
  }

  @override
  Future<void> deleteToken() async {
    token = null;
  }

  @override
  Future<bool> hasToken() async {
    return token != null && token!.isNotEmpty;
  }
}

/// Fake repository for controlling auth outcomes
class FakeAuthRepository implements AuthRepository {
  UserEntity? currentUser;
  Failure? getCurrentUserFailure;

  AuthResponseEntity? loginResult;
  Failure? loginFailure;

  AuthResponseEntity? signupResult;
  Failure? signupFailure;

  int getCurrentUserCallCount = 0;
  int loginCallCount = 0;
  int signupCallCount = 0;

  @override
  Future<UserEntity> getCurrentUser(String token) async {
    getCurrentUserCallCount++;
    if (getCurrentUserFailure != null) {
      throw getCurrentUserFailure!;
    }
    return currentUser ??
        const UserEntity(
          id: 'test_user_id',
          email: 'test@wetravel.test',
          username: 'test_user',
        );
  }

  @override
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (loginFailure != null) {
      throw loginFailure!;
    }
    return loginResult ??
        const AuthResponseEntity(
          user: UserEntity(
            id: 'login_user_id',
            email: 'login@wetravel.test',
          ),
          token: 'logged_in_jwt',
        );
  }

  @override
  Future<AuthResponseEntity> signup({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? phone,
  }) async {
    signupCallCount++;
    if (signupFailure != null) {
      throw signupFailure!;
    }
    return signupResult ??
        const AuthResponseEntity(
          user: UserEntity(
            id: 'signup_user_id',
            email: 'signup@wetravel.test',
            username: 'signup_user',
          ),
          token: 'signed_up_jwt',
        );
  }

  @override
  Future<AuthResponseEntity> googleLogin({
    required String idToken,
  }) async {
    return loginResult ??
        const AuthResponseEntity(
          user: UserEntity(
            id: 'google_user_id',
            email: 'google@wetravel.test',
            username: 'google_user',
          ),
          token: 'google_jwt',
        );
  }
}

void main() {
  group('AuthLocalDataSourceImpl', () {
    late FakeSecureStorage fakeStorage;
    late AuthLocalDataSourceImpl localDataSource;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      localDataSource = AuthLocalDataSourceImpl(storage: fakeStorage);
    });

    test('saveToken stores token under centralized AppConstants.tokenKey', () async {
      await localDataSource.saveToken('jwt-sample-token');

      expect(await fakeStorage.read(key: AppConstants.tokenKey), 'jwt-sample-token');
    });

    test('getToken returns stored token', () async {
      await fakeStorage.write(key: AppConstants.tokenKey, value: 'stored-jwt');

      final token = await localDataSource.getToken();
      expect(token, 'stored-jwt');
    });

    test('getToken returns null when key does not exist', () async {
      final token = await localDataSource.getToken();
      expect(token, isNull);
    });

    test('deleteToken removes token from secure storage', () async {
      await localDataSource.saveToken('token-to-delete');
      expect(await localDataSource.hasToken(), isTrue);

      await localDataSource.deleteToken();

      expect(await localDataSource.getToken(), isNull);
      expect(await localDataSource.hasToken(), isFalse);
    });

    test('hasToken correctly evaluates presence and emptiness', () async {
      expect(await localDataSource.hasToken(), isFalse);

      await localDataSource.saveToken('');
      expect(await localDataSource.hasToken(), isFalse);

      await localDataSource.saveToken('valid-jwt');
      expect(await localDataSource.hasToken(), isTrue);
    });
  });

  group('AuthState Model & Properties', () {
    test('state transitions and boolean getters work accurately', () {
      const initial = AuthInitialState();
      expect(initial.isLoading, isFalse);
      expect(initial.isAuthenticated, isFalse);
      expect(initial.isUnauthenticated, isFalse);
      expect(initial.isError, isFalse);
      expect(initial.user, isNull);
      expect(initial.errorMessage, isNull);

      const loading = AuthLoadingState();
      expect(loading.isLoading, isTrue);

      const user = UserEntity(id: '1', email: 'user@wetravel.test');
      const authenticated = AuthAuthenticatedState(user: user);
      expect(authenticated.isAuthenticated, isTrue);
      expect(authenticated.isLoading, isFalse);
      expect(authenticated.user, equals(user));
      expect(authenticated.errorMessage, isNull);

      const unauthenticated = AuthUnauthenticatedState();
      expect(unauthenticated.isUnauthenticated, isTrue);
      expect(unauthenticated.isAuthenticated, isFalse);

      const error = AuthErrorState('Something went wrong');
      expect(error.isError, isTrue);
      expect(error.errorMessage, 'Something went wrong');
    });
  });

  group('AuthBloc Unit Tests', () {
    late FakeAuthRepository fakeRepository;
    late FakeAuthLocalDataSource fakeLocalDataSource;
    late AuthBloc authBloc;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      fakeLocalDataSource = FakeAuthLocalDataSource();

      authBloc = AuthBloc(
        loginUseCase: LoginUseCase(fakeRepository),
        signupUseCase: SignupUseCase(fakeRepository),
        googleSignInUseCase: GoogleSignInUseCase(fakeRepository),
        getCurrentUserUseCase: GetCurrentUserUseCase(fakeRepository),
        localDataSource: fakeLocalDataSource,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitialState', () {
      expect(authBloc.state, isA<AuthInitialState>());
    });

    test('AuthCheckRequested with no token emits AuthUnauthenticatedState without calling repository', () async {
      authBloc.add(const AuthCheckRequested());
      await untilCalledOrTimeout();

      expect(authBloc.state, isA<AuthUnauthenticatedState>());
      expect(fakeRepository.getCurrentUserCallCount, 0);
    });

    test('AuthCheckRequested with valid token calls getCurrentUser and emits AuthAuthenticatedState', () async {
      await fakeLocalDataSource.saveToken('active_token');
      const expectedUser = UserEntity(
        id: 'usr_validated',
        email: 'wanderer@wetravel.test',
        username: 'wanderer',
      );
      fakeRepository.currentUser = expectedUser;

      authBloc.add(const AuthCheckRequested());
      await untilCalledOrTimeout();

      expect(authBloc.state, isA<AuthAuthenticatedState>());
      final authState = authBloc.state as AuthAuthenticatedState;
      expect(authState.user, expectedUser);
      expect(fakeRepository.getCurrentUserCallCount, 1);
      expect(await fakeLocalDataSource.getToken(), 'active_token');
    });

    test('AuthLoginRequested success saves token and emits AuthAuthenticatedState', () async {
      const user = UserEntity(id: 'usr_login', email: 'login@wetravel.test');
      fakeRepository.loginResult = const AuthResponseEntity(
        user: user,
        token: 'new_login_token',
      );

      authBloc.add(const AuthLoginRequested(
        email: 'login@wetravel.test',
        password: 'Password123!',
      ));
      await untilCalledOrTimeout();

      final state = authBloc.state;
      expect(state, isA<AuthAuthenticatedState>());
      expect((state as AuthAuthenticatedState).user, user);
      expect(await fakeLocalDataSource.getToken(), 'new_login_token');
      expect(fakeRepository.loginCallCount, 1);
    });

    test('AuthLogoutRequested deletes token and emits AuthUnauthenticatedState', () async {
      await fakeLocalDataSource.saveToken('token_to_clear');

      authBloc.add(const AuthLogoutRequested());
      await untilCalledOrTimeout();

      expect(authBloc.state, isA<AuthUnauthenticatedState>());
      expect(await fakeLocalDataSource.getToken(), isNull);
    });
  });
}

Future<void> untilCalledOrTimeout() async {
  await Future.delayed(const Duration(milliseconds: 50));
}
