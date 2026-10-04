import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/app/providers.dart';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/domain/entities/auth_response_entity.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

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
      const initial = AuthInitial();
      expect(initial.isLoading, isFalse);
      expect(initial.isAuthenticated, isFalse);
      expect(initial.isUnauthenticated, isFalse);
      expect(initial.isError, isFalse);
      expect(initial.user, isNull);
      expect(initial.errorMessage, isNull);

      const loading = AuthLoading();
      expect(loading.isLoading, isTrue);

      const user = UserEntity(id: '1', email: 'user@wetravel.test');
      const authenticated = AuthAuthenticated(user);
      expect(authenticated.isAuthenticated, isTrue);
      expect(authenticated.isLoading, isFalse);
      expect(authenticated.user, equals(user));
      expect(authenticated.errorMessage, isNull);

      const unauthenticated = AuthUnauthenticated();
      expect(unauthenticated.isUnauthenticated, isTrue);
      expect(unauthenticated.isAuthenticated, isFalse);

      const error = AuthError('Something went wrong');
      expect(error.isError, isTrue);
      expect(error.errorMessage, 'Something went wrong');
    });
  });

  group('AuthController via ProviderContainer', () {
    late FakeAuthRepository fakeRepository;
    late FakeAuthLocalDataSource fakeLocalDataSource;
    late ProviderContainer container;
    late AuthController controller;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      fakeLocalDataSource = FakeAuthLocalDataSource();

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          authLocalDataSourceProvider.overrideWithValue(fakeLocalDataSource),
        ],
      );

      controller = container.read(authControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is AuthInitial', () {
      expect(container.read(authControllerProvider), isA<AuthInitial>());
    });

    test('initialize with no token sets state to AuthUnauthenticated without calling repository', () async {
      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
      expect(fakeRepository.getCurrentUserCallCount, 0);
    });

    test('initialize with valid token calls getCurrentUser and sets AuthAuthenticated', () async {
      await fakeLocalDataSource.saveToken('active_token');
      const expectedUser = UserEntity(
        id: 'usr_validated',
        email: 'wanderer@wetravel.test',
        username: 'wanderer',
      );
      fakeRepository.currentUser = expectedUser;

      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
      final authState = container.read(authControllerProvider) as AuthAuthenticated;
      expect(authState.user, expectedUser);
      expect(fakeRepository.getCurrentUserCallCount, 1);
      // Token should remain safely in storage
      expect(await fakeLocalDataSource.getToken(), 'active_token');
    });

    test('initialize with invalid/expired token (401) deletes token and sets AuthUnauthenticated', () async {
      await fakeLocalDataSource.saveToken('expired_token');
      fakeRepository.getCurrentUserFailure = const AuthFailure('Session expired.', 401);

      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
      // Token must be purged on expired authentication
      expect(await fakeLocalDataSource.getToken(), isNull);
    });

    test('initialize with temporary network error preserves token and sets AuthError', () async {
      await fakeLocalDataSource.saveToken('active_token_offline');
      fakeRepository.getCurrentUserFailure = const NetworkFailure('No internet connection.');

      await controller.initialize();

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthError>());
      expect(state.errorMessage, 'No internet connection.');
      // Token MUST NOT be deleted due to temporary network error
      expect(await fakeLocalDataSource.getToken(), 'active_token_offline');
    });

    test('initialize with server failure (500) preserves token and sets AuthError', () async {
      await fakeLocalDataSource.saveToken('active_token_server_down');
      fakeRepository.getCurrentUserFailure = const ServerFailure('Database unreachable.', 500);

      await controller.initialize();

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthError>());
      expect(state.errorMessage, 'Database unreachable.');
      // Token must NOT be deleted due to server unavailability
      expect(await fakeLocalDataSource.getToken(), 'active_token_server_down');
    });

    test('login success saves token and transitions to AuthAuthenticated', () async {
      const user = UserEntity(id: 'usr_login', email: 'login@wetravel.test');
      fakeRepository.loginResult = const AuthResponseEntity(
        user: user,
        token: 'new_login_token',
      );

      await controller.login('login@wetravel.test', 'Password123!');

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user, user);
      expect(await fakeLocalDataSource.getToken(), 'new_login_token');
      expect(fakeRepository.loginCallCount, 1);
    });

    test('login failure transitions to AuthError and does not save token', () async {
      fakeRepository.loginFailure = const AuthFailure('Invalid email or password.', 401);

      await controller.login('wrong@wetravel.test', 'badpass');

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthError>());
      expect(state.errorMessage, 'Invalid email or password.');
      expect(await fakeLocalDataSource.getToken(), isNull);
    });

    test('signup success saves token and transitions to AuthAuthenticated', () async {
      const user = UserEntity(
        id: 'usr_signup',
        email: 'signup@wetravel.test',
        username: 'new_member',
      );
      fakeRepository.signupResult = const AuthResponseEntity(
        user: user,
        token: 'new_signup_token',
      );

      await controller.signup(
        'signup@wetravel.test',
        'Password123!',
        'new_member',
        'New Member',
        '+1000000000',
      );

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user, user);
      expect(await fakeLocalDataSource.getToken(), 'new_signup_token');
      expect(fakeRepository.signupCallCount, 1);
    });

    test('signup failure transitions to AuthError and does not save token', () async {
      fakeRepository.signupFailure = const AuthFailure('Email is already registered.', 409);

      await controller.signup(
        'dup@wetravel.test',
        'Password123!',
        'dup_user',
      );

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthError>());
      expect(state.errorMessage, 'Email is already registered.');
      expect(await fakeLocalDataSource.getToken(), isNull);
    });

    test('logout deletes token and sets AuthUnauthenticated', () async {
      await fakeLocalDataSource.saveToken('token_to_clear');
      // Set to authenticated first by login
      fakeRepository.loginResult = const AuthResponseEntity(
        user: UserEntity(id: 'active', email: 'active@wetravel.test'),
        token: 'token_to_clear',
      );
      await controller.login('active@wetravel.test', 'pass');
      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

      await controller.logout();

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
      expect(await fakeLocalDataSource.getToken(), isNull);
    });
  });
}
