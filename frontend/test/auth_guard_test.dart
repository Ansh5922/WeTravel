import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/app/providers.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/auth_guard.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/trips/presentation/pages/trips_page.dart';

class GuardTestAuthController extends AuthController {
  final AuthState initial;
  GuardTestAuthController([this.initial = const AuthInitial()]);

  @override
  AuthState build() => initial;

  @override
  Future<void> initialize() async {}

  void updateState(AuthState newState) {
    state = newState;
    authNotifierListenable.value = newState;
  }
}

class FakeGuardLocalDataSource implements AuthLocalDataSource {
  String? token;

  @override
  Future<void> saveToken(String token) async => this.token = token;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<bool> hasToken() async => token != null && token!.isNotEmpty;
}

class FakeGuardRepository extends Fake implements AuthRepository {
  UserEntity? user;
  Failure? failure;
  int getCurrentUserCallCount = 0;

  @override
  Future<UserEntity> getCurrentUser(String token) async {
    getCurrentUserCallCount++;
    if (failure != null) throw failure!;
    return user ?? const UserEntity(id: 'u1', email: 'user@wetravel.test');
  }
}

void main() {
  group('AuthGuard Unit Evaluation', () {
    test('Unauthenticated user is blocked from /home and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticated(),
        location: RouteNames.home,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is blocked from /trips and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticated(),
        location: RouteNames.trips,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is blocked from /friends and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticated(),
        location: RouteNames.friends,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is blocked from /profile and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticated(),
        location: RouteNames.profile,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is allowed to visit public routes without redirect', () {
      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticated(),
          location: RouteNames.splash,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticated(),
          location: RouteNames.onboarding,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticated(),
          location: RouteNames.login,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticated(),
          location: RouteNames.signup,
        ),
        isNull,
      );
    });

    test('Authenticated user can access protected routes without redirection', () {
      const authState = AuthAuthenticated(
        UserEntity(id: 'auth_1', email: 'test@wetravel.test'),
      );

      expect(
        AuthGuard.evaluateRedirect(state: authState, location: RouteNames.home),
        isNull,
      );
      expect(
        AuthGuard.evaluateRedirect(state: authState, location: RouteNames.trips),
        isNull,
      );
      expect(
        AuthGuard.evaluateRedirect(state: authState, location: RouteNames.friends),
        isNull,
      );
      expect(
        AuthGuard.evaluateRedirect(state: authState, location: RouteNames.profile),
        isNull,
      );
    });

    test('Authenticated user visiting /auth/login is redirected to /home', () {
      const authState = AuthAuthenticated(
        UserEntity(id: 'auth_1', email: 'test@wetravel.test'),
      );

      final redirect = AuthGuard.evaluateRedirect(
        state: authState,
        location: RouteNames.login,
      );
      expect(redirect, RouteNames.home);
    });

    test('Authenticated user visiting /auth/signup is redirected to /home', () {
      const authState = AuthAuthenticated(
        UserEntity(id: 'auth_1', email: 'test@wetravel.test'),
      );

      final redirect = AuthGuard.evaluateRedirect(
        state: authState,
        location: RouteNames.signup,
      );
      expect(redirect, RouteNames.home);
    });

    test('AuthInitial and AuthLoading do not redirect prematurely to preserve startup flow', () {
      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthInitial(),
          location: RouteNames.splash,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthLoading(),
          location: RouteNames.splash,
        ),
        isNull,
      );
    });

    test('AuthError does not redirect to login and does not act as unauthenticated', () {
      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthError('Server down'),
          location: RouteNames.home,
        ),
        isNull,
      );
    });

    test('No redirect loops exist for either state', () {
      // 1. Unauthenticated on /login returns null
      final loginRedirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticated(),
        location: RouteNames.login,
      );
      expect(loginRedirect, isNull);

      // 2. Authenticated on /home returns null
      const authState = AuthAuthenticated(UserEntity(id: '1', email: 'a@b.com'));
      final homeRedirect = AuthGuard.evaluateRedirect(
        state: authState,
        location: RouteNames.home,
      );
      expect(homeRedirect, isNull);
    });
  });

  group('Startup Session Restoration Lifecycle', () {
    late FakeGuardRepository fakeRepository;
    late FakeGuardLocalDataSource fakeLocalDataSource;

    setUp(() {
      fakeRepository = FakeGuardRepository();
      fakeLocalDataSource = FakeGuardLocalDataSource();
    });

    test('No token → unauthenticated and does not call /me', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          authLocalDataSourceProvider.overrideWithValue(fakeLocalDataSource),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
      expect(fakeRepository.getCurrentUserCallCount, 0);
    });

    test('Valid token → GET /api/auth/me → authenticated', () async {
      fakeLocalDataSource.token = 'valid_session_jwt';
      fakeRepository.user = const UserEntity(
        id: 'u_restored',
        email: 'restored@wetravel.test',
        username: 'restored_traveler',
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          authLocalDataSourceProvider.overrideWithValue(fakeLocalDataSource),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
      final auth = container.read(authControllerProvider) as AuthAuthenticated;
      expect(auth.user.email, 'restored@wetravel.test');
      expect(fakeRepository.getCurrentUserCallCount, 1);
    });

    test('Invalid/expired token (401) → delete token → unauthenticated', () async {
      fakeLocalDataSource.token = 'expired_session_jwt';
      fakeRepository.failure = const AuthFailure('Session expired.', 401);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          authLocalDataSourceProvider.overrideWithValue(fakeLocalDataSource),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
      expect(fakeLocalDataSource.token, isNull);
    });

    test('Network error → preserve token → AuthError (user not logged out)', () async {
      fakeLocalDataSource.token = 'valid_token_offline';
      fakeRepository.failure = const NetworkFailure('No internet connection.');

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
          authLocalDataSourceProvider.overrideWithValue(fakeLocalDataSource),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.initialize();

      expect(container.read(authControllerProvider), isA<AuthError>());
      expect(container.read(authControllerProvider).errorMessage, 'No internet connection.');
      // Token must NOT be deleted
      expect(fakeLocalDataSource.token, 'valid_token_offline');
    });
  });

  group('Router Auth Guard Widget Flow', () {
    testWidgets('Unauthenticated user attempting /home is redirected to /auth/login', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(const AuthUnauthenticated()),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.home);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Unauthenticated user attempting /trips is redirected to /auth/login', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(const AuthUnauthenticated()),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.trips);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Unauthenticated user attempting /friends is redirected to /auth/login', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(const AuthUnauthenticated()),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.friends);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Unauthenticated user attempting /profile is redirected to /auth/login', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(const AuthUnauthenticated()),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.profile);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Authenticated user can access /home and /trips directly', (tester) async {
      const authState = AuthAuthenticated(
        UserEntity(id: 'usr_auth', email: 'auth@wetravel.test'),
      );
      authNotifierListenable.value = authState;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(authState),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.home);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      appRouter.go(RouteNames.trips);
      await tester.pumpAndSettle();
      expect(find.byType(TripsPage), findsOneWidget);
    });

    testWidgets('Authenticated user navigating to /auth/login is redirected to /home', (tester) async {
      const authState = AuthAuthenticated(
        UserEntity(id: 'usr_auth', email: 'auth@wetravel.test'),
      );
      authNotifierListenable.value = authState;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(authState),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.login);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Authenticated user navigating to /auth/signup is redirected to /home', (tester) async {
      const authState = AuthAuthenticated(
        UserEntity(id: 'usr_auth', email: 'auth@wetravel.test'),
      );
      authNotifierListenable.value = authState;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => GuardTestAuthController(authState),
            ),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.signup);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Logout transitions to AuthUnauthenticated and redirects protected route to /auth/login', (tester) async {
      final fakeLocalDataSource = FakeGuardLocalDataSource();
      fakeLocalDataSource.token = 'active_jwt';

      final container = ProviderContainer(
        overrides: [
          authLocalDataSourceProvider.overrideWithValue(fakeLocalDataSource),
        ],
      );
      addTearDown(container.dispose);

      const authState = AuthAuthenticated(
        UserEntity(id: 'usr_auth', email: 'auth@wetravel.test'),
      );
      authNotifierListenable.value = authState;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.home);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      // Trigger logout
      await container.read(authControllerProvider.notifier).logout();
      await tester.pumpAndSettle();

      expect(authNotifierListenable.value, isA<AuthUnauthenticated>());
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
