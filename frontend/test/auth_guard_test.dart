import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/auth_guard.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/trips/presentation/pages/trips_page.dart';

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
        state: const AuthUnauthenticatedState(),
        location: RouteNames.home,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is blocked from /trips and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticatedState(),
        location: RouteNames.trips,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is blocked from /friends and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticatedState(),
        location: RouteNames.friends,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is blocked from /profile and redirected to /auth/login', () {
      final redirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticatedState(),
        location: RouteNames.profile,
      );
      expect(redirect, RouteNames.login);
    });

    test('Unauthenticated user is allowed to visit public routes without redirect', () {
      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticatedState(),
          location: RouteNames.splash,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticatedState(),
          location: RouteNames.onboarding,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticatedState(),
          location: RouteNames.login,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthUnauthenticatedState(),
          location: RouteNames.signup,
        ),
        isNull,
      );
    });

    test('Authenticated user can access protected routes without redirection', () {
      const authState = AuthAuthenticatedState(
        user: UserEntity(id: 'auth_1', email: 'test@wetravel.test'),
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
      const authState = AuthAuthenticatedState(
        user: UserEntity(id: 'auth_1', email: 'test@wetravel.test'),
      );

      final redirect = AuthGuard.evaluateRedirect(
        state: authState,
        location: RouteNames.login,
      );
      expect(redirect, RouteNames.home);
    });

    test('Authenticated user visiting /auth/signup is redirected to /home', () {
      const authState = AuthAuthenticatedState(
        user: UserEntity(id: 'auth_1', email: 'test@wetravel.test'),
      );

      final redirect = AuthGuard.evaluateRedirect(
        state: authState,
        location: RouteNames.signup,
      );
      expect(redirect, RouteNames.home);
    });

    test('AuthInitialState and AuthLoadingState do not redirect prematurely to preserve startup flow', () {
      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthInitialState(),
          location: RouteNames.splash,
        ),
        isNull,
      );

      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthLoadingState(),
          location: RouteNames.splash,
        ),
        isNull,
      );
    });

    test('AuthErrorState does not redirect to login and does not act as unauthenticated', () {
      expect(
        AuthGuard.evaluateRedirect(
          state: const AuthErrorState('Server down'),
          location: RouteNames.home,
        ),
        isNull,
      );
    });

    test('No redirect loops exist for either state', () {
      final loginRedirect = AuthGuard.evaluateRedirect(
        state: const AuthUnauthenticatedState(),
        location: RouteNames.login,
      );
      expect(loginRedirect, isNull);

      const authState = AuthAuthenticatedState(
        user: UserEntity(id: '1', email: 'a@b.com'),
      );
      final homeRedirect = AuthGuard.evaluateRedirect(
        state: authState,
        location: RouteNames.home,
      );
      expect(homeRedirect, isNull);
    });
  });

  group('Router Auth Guard Widget Flow', () {
    testWidgets('Unauthenticated user attempting /home is redirected to /auth/login', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticatedState();

      await tester.pumpWidget(
        const WeTravelApp(autoInitialize: false),
      );

      appRouter.go(RouteNames.home);
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Authenticated user can access /home and /trips directly', (tester) async {
      const authState = AuthAuthenticatedState(
        user: UserEntity(id: 'usr_auth', email: 'auth@wetravel.test'),
      );
      authNotifierListenable.value = authState;

      await tester.pumpWidget(
        const WeTravelApp(autoInitialize: false),
      );

      appRouter.go(RouteNames.home);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      appRouter.go(RouteNames.trips);
      await tester.pumpAndSettle();
      expect(find.byType(TripsPage), findsOneWidget);
    });
  });
}
