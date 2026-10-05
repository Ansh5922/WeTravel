// BLoC Event definitions for Auth Feature.
import 'package:equatable/equatable.dart';

/// Sealed base event hierarchy for all Auth BLoC events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered on application startup to verify local JWT token session.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered when a user submits email and password credentials.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when a user submits registration form fields.
class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final String? fullName;
  final String? phone;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    required this.username,
    this.fullName,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, username, fullName, phone];
}

/// Event triggered when a user clicks 'Continue with Google'.
class AuthGoogleSignInRequested extends AuthEvent {
  final String? webClientId;

  const AuthGoogleSignInRequested({this.webClientId});

  @override
  List<Object?> get props => [webClientId];
}

/// Event triggered when a user clicks Logout.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
