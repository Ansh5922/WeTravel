// BLoC Event Handler logic for Auth Feature with complete terminal debug logging.
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../../../core/error/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Clean Architecture Business Logic Component (BLoC) for Auth operations.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthLocalDataSource _localDataSource;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required SignupUseCase signupUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthLocalDataSource localDataSource,
  })  : _loginUseCase = loginUseCase,
        _signupUseCase = signupUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _localDataSource = localDataSource,
        super(const AuthInitialState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  /// Handles initial application startup session check.
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] 🚀 Event: AuthCheckRequested -> Checking local session token...');
    final token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[AUTH_BLOC] 🔒 No active session token found. State -> AuthUnauthenticatedState');
      emit(const AuthUnauthenticatedState());
      return;
    }

    try {
      debugPrint('[AUTH_BLOC] 📡 Token found. Fetching current user profile from GET /api/auth/me...');
      final user = await _getCurrentUserUseCase.execute(token);
      debugPrint('[AUTH_BLOC] ✅ Session restored! User: ${user.email} (${user.id})');
      emit(AuthAuthenticatedState(user: user));
    } catch (e) {
      debugPrint('[AUTH_BLOC] ⚠️ Session restoration failed: $e. Preserving local state.');
      emit(AuthErrorState(e.toString()));
    }
  }

  /// Handles email and password login submission.
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] 🔑 Event: AuthLoginRequested -> Email: ${event.email}');
    emit(const AuthLoadingState());
    try {
      final result = await _loginUseCase.execute(
        email: event.email,
        password: event.password,
      );
      if (result.token != null && result.token!.isNotEmpty) {
        await _localDataSource.saveToken(result.token!);
        debugPrint('[AUTH_BLOC] 💾 JWT Token saved to secure storage.');
      }
      debugPrint('[AUTH_BLOC] ✅ Login Success! User ID: ${result.user.id}');
      emit(AuthAuthenticatedState(user: result.user, isFirstTimeUser: false));
    } on Failure catch (e) {
      debugPrint('[AUTH_BLOC] ❌ Login Failure: ${e.message}');
      emit(AuthErrorState(e.message));
    } catch (e) {
      debugPrint('[AUTH_BLOC] 💥 Unexpected Login Error: $e');
      emit(AuthErrorState(e.toString()));
    }
  }

  /// Handles new user registration submission.
  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] 📝 Event: AuthSignupRequested -> Email: ${event.email}, Username: ${event.username}');
    emit(const AuthLoadingState());
    try {
      final result = await _signupUseCase.execute(
        email: event.email,
        password: event.password,
        username: event.username,
        fullName: event.fullName,
        phone: event.phone,
      );
      if (result.token != null && result.token!.isNotEmpty) {
        await _localDataSource.saveToken(result.token!);
        debugPrint('[AUTH_BLOC] 💾 JWT Token saved to secure storage.');
      }
      debugPrint('[AUTH_BLOC] 🎉 Signup Success! User ID: ${result.user.id}. Redirecting to Preferences...');
      emit(AuthAuthenticatedState(user: result.user, isFirstTimeUser: true));
    } on Failure catch (e) {
      debugPrint('[AUTH_BLOC] ❌ Signup Failure: ${e.message}');
      emit(AuthErrorState(e.message));
    } catch (e) {
      debugPrint('[AUTH_BLOC] 💥 Unexpected Signup Error: $e');
      emit(AuthErrorState(e.toString()));
    }
  }

  /// Handles Google OAuth 2.0 sign-in.
  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] 🌐 Event: AuthGoogleSignInRequested (isWeb: $kIsWeb)');
    emit(const AuthLoadingState());
    try {
      const defaultWebClientId = '651498220095-lr27c795r377789g01htoptt5c61c9rl.apps.googleusercontent.com';
      final GoogleSignIn googleSignInClient = GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: kIsWeb ? (event.webClientId ?? defaultWebClientId) : null,
        serverClientId: kIsWeb ? null : (event.webClientId ?? defaultWebClientId),
      );

      final googleUser = await googleSignInClient.signIn();
      if (googleUser == null) {
        debugPrint('[AUTH_BLOC] ℹ️ Google Sign-In popup closed or cancelled by user.');
        emit(const AuthUnauthenticatedState());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final token = googleAuth.idToken ?? googleAuth.accessToken;

      if (token == null || token.isEmpty) {
        debugPrint('[AUTH_BLOC] ❌ Could not retrieve Google authentication token from client.');
        emit(const AuthErrorState('Could not retrieve Google authentication token.'));
        return;
      }

      debugPrint('[AUTH_BLOC] 📡 Google token retrieved. Authenticating with backend...');
      final result = await _googleSignInUseCase.execute(idToken: token);
      if (result.token != null && result.token!.isNotEmpty) {
        await _localDataSource.saveToken(result.token!);
        debugPrint('[AUTH_BLOC] 💾 JWT Token saved to secure storage.');
      }
      debugPrint('[AUTH_BLOC] ✅ Google Auth Success! User ID: ${result.user.id}');
      emit(AuthAuthenticatedState(user: result.user, isFirstTimeUser: false));
    } on Failure catch (e) {
      debugPrint('[AUTH_BLOC] ❌ Google Auth Failure: ${e.message}');
      emit(AuthErrorState(e.message));
    } catch (e) {
      debugPrint('[AUTH_BLOC] 💥 Unexpected Google Auth Error: $e');
      emit(AuthErrorState(e.toString()));
    }
  }

  /// Handles user logout.
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AUTH_BLOC] 🚪 Event: AuthLogoutRequested -> Deleting local token session...');
    await _localDataSource.deleteToken();
    debugPrint('[AUTH_BLOC] 🔒 User logged out successfully. State -> AuthUnauthenticatedState');
    emit(const AuthUnauthenticatedState());
  }
}
