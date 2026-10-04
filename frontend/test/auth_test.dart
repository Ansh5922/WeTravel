import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/auth_guard.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';

class TestAuthController extends AuthController {
  final AuthState initialState;
  bool loginCalled = false;
  String? lastLoginEmail;
  String? lastLoginPassword;

  bool signupCalled = false;
  String? lastSignupEmail;
  String? lastSignupPassword;
  String? lastSignupUsername;
  String? lastSignupFullName;
  String? lastSignupPhone;

  TestAuthController([this.initialState = const AuthInitial()]);

  @override
  AuthState build() => initialState;

  @override
  Future<void> initialize() async {}

  void triggerState(AuthState newState) {
    state = newState;
    authNotifierListenable.value = newState;
  }

  @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
    lastLoginEmail = email;
    lastLoginPassword = password;
  }

  @override
  Future<void> signup(
    String email,
    String password,
    String username, [
    String? fullName,
    String? phone,
  ]) async {
    signupCalled = true;
    lastSignupEmail = email;
    lastSignupPassword = password;
    lastSignupUsername = username;
    lastSignupFullName = fullName;
    lastSignupPhone = phone;
  }
}

void main() {
  testWidgets('LoginPage renders properly, triggers validation, and navigates to Signup', (tester) async {
    authNotifierListenable.value = const AuthUnauthenticated();

    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(autoInitialize: false),
      ),
    );

    appRouter.go(RouteNames.login);
    await tester.pumpAndSettle();

    // Verify presence of core elements
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('Your next journey starts here.'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);

    // Test form validation on empty submit
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    // Test password toggle
    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hide password'), findsOneWidget);

    // Test navigation to Signup
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('SignupPage renders properly, triggers contract validation, and navigates to Login', (tester) async {
    authNotifierListenable.value = const AuthUnauthenticated();

    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(autoInitialize: false),
      ),
    );

    appRouter.go(RouteNames.signup);
    await tester.pumpAndSettle();

    // Verify presence of core elements
    expect(find.byType(SignupPage), findsOneWidget);
    expect(find.text('Start your journey.'), findsOneWidget);
    expect(find.text('Create your account and start planning together.'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Test form validation on empty submit
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Username is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    // Test invalid format validation
    await tester.enterText(find.byType(TextFormField).at(0), 'ab'); // too short username
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
    await tester.enterText(find.byType(TextFormField).at(2), 'short'); // < 8 chars

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Username must be 3–50 characters long.'), findsOneWidget);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters long.'), findsOneWidget);

    // Test navigation back to Login
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  group('LoginPage AuthController Integration', () {
    late TestAuthController testController;

    setUp(() {
      testController = TestAuthController();
    });

    testWidgets('Valid form submits login to AuthController', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => testController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.login);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'traveler@wetravel.test');
      await tester.enterText(find.byType(TextFormField).at(1), 'SecurePass123!');

      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(testController.loginCalled, isTrue);
      expect(testController.lastLoginEmail, 'traveler@wetravel.test');
      expect(testController.lastLoginPassword, 'SecurePass123!');
    });

    testWidgets('Invalid form does not call AuthController.login', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => testController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.login);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), '');

      await tester.tap(find.text('Log in'));
      await tester.pump();

      expect(testController.loginCalled, isFalse);
    });

    testWidgets('Loading state disables submit button and shows progress indicator', (tester) async {
      final loadingController = TestAuthController(const AuthLoading());
      authNotifierListenable.value = const AuthLoading();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => loadingController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.login);
      await tester.pump();

      final buttonFinder = find.byType(ElevatedButton);
      final elevatedButton = tester.widget<ElevatedButton>(buttonFinder);
      expect(elevatedButton.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthError displays an error message', (tester) async {
      final errorController = TestAuthController(
        const AuthError('Invalid email or password.'),
      );
      authNotifierListenable.value = const AuthError('Invalid email or password.');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => errorController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.login);
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('Successful authentication navigates to /home', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => testController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.login);
      await tester.pumpAndSettle();

      // Trigger transition to AuthAuthenticated
      testController.triggerState(
        const AuthAuthenticated(
          UserEntity(id: 'auth_usr_1', email: 'verified@wetravel.test'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('SignupPage AuthController Integration', () {
    late TestAuthController testController;

    setUp(() {
      testController = TestAuthController();
    });

    testWidgets('Valid form submits signup with optional fields to AuthController', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => testController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.signup);
      await tester.pumpAndSettle();

      // Enter all fields
      await tester.enterText(find.byType(TextFormField).at(0), 'alex_m');
      await tester.enterText(find.byType(TextFormField).at(1), 'alex@wetravel.test');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecretPass888!');
      await tester.enterText(find.byType(TextFormField).at(3), 'Alex Mercer');
      await tester.enterText(find.byType(TextFormField).at(4), '+1555123456');

      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(testController.signupCalled, isTrue);
      expect(testController.lastSignupUsername, 'alex_m');
      expect(testController.lastSignupEmail, 'alex@wetravel.test');
      expect(testController.lastSignupPassword, 'SecretPass888!');
      expect(testController.lastSignupFullName, 'Alex Mercer');
      expect(testController.lastSignupPhone, '+1555123456');
    });

    testWidgets('Invalid form does not call AuthController.signup', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => testController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.signup);
      await tester.pumpAndSettle();

      // Empty form
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(testController.signupCalled, isFalse);
    });

    testWidgets('Loading state disables submit button and shows progress indicator', (tester) async {
      final loadingController = TestAuthController(const AuthLoading());
      authNotifierListenable.value = const AuthLoading();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => loadingController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.signup);
      await tester.pump();

      final buttonFinder = find.byType(ElevatedButton);
      final elevatedButton = tester.widget<ElevatedButton>(buttonFinder);
      expect(elevatedButton.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthError displays an error message', (tester) async {
      final errorController = TestAuthController(
        const AuthError('Email is already registered.'),
      );
      authNotifierListenable.value = const AuthError('Email is already registered.');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => errorController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.signup);
      await tester.pumpAndSettle();

      expect(find.text('Email is already registered.'), findsOneWidget);
    });

    testWidgets('Successful authentication navigates to /home', (tester) async {
      authNotifierListenable.value = const AuthUnauthenticated();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(() => testController),
          ],
          child: const WeTravelApp(autoInitialize: false),
        ),
      );

      appRouter.go(RouteNames.signup);
      await tester.pumpAndSettle();

      testController.triggerState(
        const AuthAuthenticated(
          UserEntity(id: 'signup_usr_1', email: 'registered@wetravel.test'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
