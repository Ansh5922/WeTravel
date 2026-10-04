import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../app/providers.dart';

/// Authentication state hierarchy representing all phases of the auth lifecycle.
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isLoading => this is AuthLoading;
  bool get isUnauthenticated => this is AuthUnauthenticated;
  bool get isError => this is AuthError;

  UserEntity? get user =>
      this is AuthAuthenticated ? (this as AuthAuthenticated).user : null;
  String? get errorMessage =>
      this is AuthError ? (this as AuthError).message : null;
}

class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthInitial;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthInitial()';
}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLoading;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthLoading()';
}

class AuthAuthenticated extends AuthState {
  @override
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'AuthAuthenticated(user: $user)';
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthUnauthenticated;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthUnauthenticated()';
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AuthError(message: $message)';
}

/// Riverpod Notifier controlling authentication flows and session state.
class AuthController extends Notifier<AuthState> {
  final AuthRepository? overrideAuthRepository;
  final AuthLocalDataSource? overrideLocalDataSource;

  AuthController({
    this.overrideAuthRepository,
    this.overrideLocalDataSource,
  });

  AuthRepository get authRepository =>
      overrideAuthRepository ?? ref.read(authRepositoryProvider);

  AuthLocalDataSource get localDataSource =>
      overrideLocalDataSource ?? ref.read(authLocalDataSourceProvider);

  @override
  AuthState build() {
    return const AuthInitial();
  }

  /// Initializes authentication state:
  /// 1. Reads JWT from secure storage.
  /// 2. If no token -> unauthenticated.
  /// 3. If token exists -> calls GET /api/auth/me.
  /// 4. If successful -> authenticated with returned user.
  /// 5. If token is expired/invalid (401/403) -> deletes token & unauthenticated.
  /// 6. If network/server failure -> preserves token and exposes error state without crashing.
  Future<void> initialize() async {
    state = const AuthLoading();
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.trim().isEmpty) {
        state = const AuthUnauthenticated();
        return;
      }

      final user = await authRepository.getCurrentUser(token);
      state = AuthAuthenticated(user);
    } on AuthFailure catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await localDataSource.deleteToken();
        state = const AuthUnauthenticated();
      } else {
        state = AuthError(e.message);
      }
    } on AuthException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await localDataSource.deleteToken();
        state = const AuthUnauthenticated();
      } else {
        state = AuthError(e.message);
      }
    } on NetworkFailure catch (e) {
      // Preserve token on network disruption
      state = AuthError(e.message);
    } on NetworkException catch (e) {
      // Preserve token on network disruption
      state = AuthError(e.message);
    } on ServerFailure catch (e) {
      // Preserve token on server errors
      state = AuthError(e.message);
    } on ServerException catch (e) {
      // Preserve token on server errors
      state = AuthError(e.message);
    } on Failure catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Logs in an existing user with email and password.
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final result = await authRepository.login(
        email: email,
        password: password,
      );
      if (result.token != null && result.token!.isNotEmpty) {
        await localDataSource.saveToken(result.token!);
      }
      state = AuthAuthenticated(result.user);
    } on Failure catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Registers a new user with required credentials and optional profile fields.
  Future<void> signup(
    String email,
    String password,
    String username, [
    String? fullName,
    String? phone,
  ]) async {
    state = const AuthLoading();
    try {
      final result = await authRepository.signup(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phone: phone,
      );
      if (result.token != null && result.token!.isNotEmpty) {
        await localDataSource.saveToken(result.token!);
      }
      state = AuthAuthenticated(result.user);
    } on Failure catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Authenticates using Google OAuth 2.0.
  Future<void> googleSignIn({String? webClientId}) async {
    state = const AuthLoading();
    try {
      const defaultWebClientId = '651498220095-lr27c795r377789g01htoptt5c61c9rl.apps.googleusercontent.com';
      final GoogleSignIn googleSignInClient = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: webClientId ?? defaultWebClientId,
      );

      final googleUser = await googleSignInClient.signIn();
      if (googleUser == null) {
        // User cancelled Google sign-in dialog
        state = const AuthUnauthenticated();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        state = const AuthError('Could not retrieve Google ID Token.');
        return;
      }

      final result = await authRepository.googleLogin(idToken: idToken);
      if (result.token != null && result.token!.isNotEmpty) {
        await localDataSource.saveToken(result.token!);
      }
      state = AuthAuthenticated(result.user);
    } on Failure catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Logs out by deleting JWT from secure storage and transitioning to unauthenticated state.
  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await localDataSource.deleteToken();
    } catch (_) {
      // local deletion error ignored to ensure local session reset
    } finally {
      state = const AuthUnauthenticated();
    }
  }
}

/// Provider for [AuthController] managing state transitions.
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Provider for reading the current [AuthState].
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});

/// Central auth provider alias.
final authProvider = authStateProvider;
