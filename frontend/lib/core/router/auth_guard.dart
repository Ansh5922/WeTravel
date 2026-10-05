// Route guard & status listenable evaluating navigation security rules.
import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'route_names.dart';

/// Authentication status representation for navigation guards.
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

/// Listenable that GoRouter observes to re-evaluate redirect rules reactively.
final authNotifierListenable = ValueNotifier<AuthState>(const AuthInitialState());

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
        (state is AuthAuthenticatedState
            ? AuthStatus.authenticated
            : (state is AuthUnauthenticatedState
                ? AuthStatus.unauthenticated
                : AuthStatus.initial));

    final isPublic = isPublicRoute(location);
    final isAuthScreen = location == RouteNames.login ||
        location == RouteNames.signup ||
        location.startsWith('/auth');

    // 1. Authenticated user behavior:
    if (effectiveStatus == AuthStatus.authenticated) {
      if (isAuthScreen || location == RouteNames.onboarding) {
        return RouteNames.home;
      }
      return null;
    }

    // 2. Unauthenticated user behavior:
    if (effectiveStatus == AuthStatus.unauthenticated) {
      if (!isPublic) {
        return RouteNames.login;
      }
      return null;
    }

    // 3. AuthInitialState, AuthLoadingState, or AuthErrorState:
    return null;
  }
}
