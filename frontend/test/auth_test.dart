// BLoC Unit & Widget Test Suite for Auth Feature.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/auth/domain/entities/auth_response_entity.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:frontend/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';

class MockAuthRepository implements AuthRepository {
  bool loginCalled = false;
  String? lastLoginEmail;
  String? lastLoginPassword;

  bool signupCalled = false;
  String? lastSignupEmail;
  String? lastSignupPassword;
  String? lastSignupUsername;
  String? lastSignupFullName;
  String? lastSignupPhone;

  @override
  Future<AuthResponseEntity> login({required String email, required String password}) async {
    loginCalled = true;
    lastLoginEmail = email;
    lastLoginPassword = password;
    return const AuthResponseEntity(
      user: UserEntity(id: 'usr_mock_1', email: 'mock@wetravel.test'),
      token: 'jwt_mock_token',
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
    signupCalled = true;
    lastSignupEmail = email;
    lastSignupPassword = password;
    lastSignupUsername = username;
    lastSignupFullName = fullName;
    lastSignupPhone = phone;
    return const AuthResponseEntity(
      user: UserEntity(id: 'usr_mock_signup', email: 'registered@wetravel.test'),
      token: 'jwt_signup_token',
    );
  }

  @override
  Future<AuthResponseEntity> googleLogin({required String idToken}) async {
    return const AuthResponseEntity(
      user: UserEntity(id: 'usr_google', email: 'google@wetravel.test'),
      token: 'jwt_google_token',
    );
  }

  @override
  Future<UserEntity> getCurrentUser(String token) async {
    return const UserEntity(id: 'usr_mock_1', email: 'mock@wetravel.test');
  }
}

class MockAuthLocalDataSource implements AuthLocalDataSource {
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;

  @override
  Future<bool> hasToken() async => _token != null && _token!.isNotEmpty;
}

void main() {
  late MockAuthRepository mockRepository;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthBloc authBloc;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockLocalDataSource = MockAuthLocalDataSource();
    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(mockRepository),
      signupUseCase: SignupUseCase(mockRepository),
      googleSignInUseCase: GoogleSignInUseCase(mockRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(mockRepository),
      localDataSource: mockLocalDataSource,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('AuthBloc emits AuthAuthenticatedState on AuthLoginRequested', () async {
    final expectedStates = [
      const AuthLoadingState(),
      const AuthAuthenticatedState(
        user: UserEntity(id: 'usr_mock_1', email: 'mock@wetravel.test'),
        isFirstTimeUser: false,
      ),
    ];

    expectLater(authBloc.stream, emitsInOrder(expectedStates));

    authBloc.add(
      const AuthLoginRequested(
        email: 'pandeysuyash@gmail.com',
        password: 'Password123',
      ),
    );
  });

  test('AuthBloc emits AuthAuthenticatedState with isFirstTimeUser=true on AuthSignupRequested', () async {
    final expectedStates = [
      const AuthLoadingState(),
      const AuthAuthenticatedState(
        user: UserEntity(id: 'usr_mock_signup', email: 'registered@wetravel.test'),
        isFirstTimeUser: true,
      ),
    ];

    expectLater(authBloc.stream, emitsInOrder(expectedStates));

    authBloc.add(
      const AuthSignupRequested(
        email: 'registered@wetravel.test',
        password: 'Password123',
        username: 'suyash_p',
      ),
    );
  });

  testWidgets('LoginPage renders properly and submits login via AuthBloc', (tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );

    appRouter.go(RouteNames.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);

    final loginButton = find.widgetWithText(ElevatedButton, 'Log in');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(mockRepository.loginCalled, isTrue);
  });
}
