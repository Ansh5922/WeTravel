import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import 'route_names.dart';

/// Authentication status representation for navigation guards.
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

/// Listenable that GoRouter observes to re-evaluate redirect rules reactively.
final authNotifierListenable = ValueNotifier<AuthState>(const AuthInitial());

/// Riverpod provider for router authentication guarding.
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authControllerProvider);
  if (authState is AuthAuthenticated) {
    return AuthStatus.authenticated;
  } else if (authState is AuthUnauthenticated) {
    return AuthStatus.unauthenticated;
  }
  return AuthStatus.initial;
});

/// Centralized route guarding logic separating public and protected surfaces.
class AuthGuard {
  AuthGuard._();

  /// Public routes accessible without active session tokens.
  static const Set<String> publicRoutes = {
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.login,
    RouteNames.signup,
  };

  /// Returns true if the requested route is public.
  static bool isPublicRoute(String location) {
    return publicRoutes.contains(location) || location.startsWith('/auth');
  }

  /// Evaluates redirect logic given the current [AuthState] or [AuthStatus] and target [location].
  /// Returns null when access is granted without redirection.
  static String? evaluateRedirect({
    AuthState? state,
    AuthStatus? status,
    required String location,
  }) {
    final effectiveStatus = status ??
        (state is AuthAuthenticated
            ? AuthStatus.authenticated
            : (state is AuthUnauthenticated
                ? AuthStatus.unauthenticated
                : AuthStatus.initial));

    final isPublic = isPublicRoute(location);
    final isAuthScreen = location == RouteNames.login ||
        location == RouteNames.signup ||
        location.startsWith('/auth');

    // 1. Authenticated user behavior:
    // - Allow protected routes
    // - /auth/login → /home
    // - /auth/signup → /home
    // - /onboarding → /home (prevent onboarding loop for logged-in users)
    if (effectiveStatus == AuthStatus.authenticated) {
      if (isAuthScreen || location == RouteNames.onboarding) {
        return RouteNames.home;
      }
      return null;
    }

    // 2. Unauthenticated user behavior:
    // - Protected route → /auth/login
    // - Public routes → allowed
    if (effectiveStatus == AuthStatus.unauthenticated) {
      if (!isPublic) {
        return RouteNames.login;
      }
      return null;
    }

    // 3. AuthInitial, AuthLoading, or AuthError:
    // - Do NOT redirect to login prematurely.
    // - Keep the startup/splash flow.
    // - If AuthError: do NOT treat it as unauthenticated, do NOT delete the JWT.
    return null;
  }
}
