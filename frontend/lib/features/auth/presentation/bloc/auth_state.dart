// BLoC State definitions for Auth Feature.
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Sealed base state hierarchy for all Auth BLoC states.
sealed class AuthState extends Equatable {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticatedState;
  bool get isLoading => this is AuthLoadingState;
  bool get isUnauthenticated => this is AuthUnauthenticatedState;
  bool get isError => this is AuthErrorState;

  UserEntity? get user =>
      this is AuthAuthenticatedState ? (this as AuthAuthenticatedState).user : null;
  String? get errorMessage =>
      this is AuthErrorState ? (this as AuthErrorState).message : null;

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state on startup.
class AuthInitialState extends AuthState {
  const AuthInitialState();
}

/// Loading state displayed during async HTTP requests.
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// Successfully authenticated user state containing UserEntity payload.
class AuthAuthenticatedState extends AuthState {
  @override
  final UserEntity user;
  final bool isFirstTimeUser;

  const AuthAuthenticatedState({
    required this.user,
    this.isFirstTimeUser = false,
  });

  @override
  List<Object?> get props => [user, isFirstTimeUser];
}

/// Unauthenticated state indicating user is logged out or session expired.
class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
}

/// Error state containing human-readable error messages for UI alerts.
class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
