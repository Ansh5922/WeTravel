// WeTravel Signup Screen using Flutter BLoC Architecture.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

/// WeTravel Signup Screen connected to AuthBloc for clean reactive state management.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();

      bloc.add(
        AuthSignupRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          fullName: fullName.isNotEmpty ? fullName : null,
          phone: phone.isNotEmpty ? phone : null,
        ),
      );
    }
  }

  void _onGoogleSignIn() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;
    bloc.add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState) {
          // Redirect first-time signups to Preferences Setup!
          context.go(RouteNames.preferences);
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: AppColors.backgroundWarm,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Editorial Header ─────────────────────────────────────
                        const AuthHeader(
                          title: 'Create account.',
                          subtitle: 'Start planning unforgettable trips together.',
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // ── Error Banner ─────────────────────────────────────────
                        if (state is AuthErrorState) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.08),
                              borderRadius: AppRadius.card,
                              border: Border.all(
                                color: AppColors.errorRed.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.errorRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.message,
                                    style: AppTypography.bodySmall(
                                      color: AppColors.errorRed,
                                    ).copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // ── Username Input Field ─────────────────────────────────
                        AuthTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'suyash_p',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.validateUsername,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Email Input Field ────────────────────────────────────
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'your.email@wetravel.test',
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.validateEmail,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Password Input Field ─────────────────────────────────
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          obscureText: _obscurePassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Full Name Input Field (Optional) ─────────────────────
                        AuthTextField(
                          controller: _fullNameController,
                          label: 'Full Name (Optional)',
                          hint: 'Suyash Pandey',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.validateFullName,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // ── Phone Input Field (Optional) ─────────────────────────
                        AuthTextField(
                          controller: _phoneController,
                          label: 'Phone (Optional)',
                          hint: '+91 9876543210',
                          keyboardType: TextInputType.phone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.validatePhone,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Main Action: Create Account Button ───────────────────
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onCreateAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDeepTeal,
                              disabledBackgroundColor:
                                  AppColors.primaryDeepTeal.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.surfaceWhite,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Create account',
                                    style: AppTypography.labelLarge(
                                      color: AppColors.surfaceWhite,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // ── OR Divider ──────────────────────────────────────────
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.borderWarm)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                'OR',
                                style: AppTypography.bodySmall(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppColors.borderWarm)),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // ── Google Sign In Button ────────────────────────────────
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _onGoogleSignIn,
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: AppColors.primaryDeepTeal),
                            label: Text(
                              'Continue with Google',
                              style: AppTypography.labelLarge(
                                color: AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderWarm),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Secondary Navigation: "Log in" ───────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: AppTypography.bodySmall(
                                color: AppColors.textSecondary,
                              ).copyWith(fontSize: 13.5),
                            ),
                            TextButton(
                              onPressed: () => context.go(RouteNames.login),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Log in',
                                style: AppTypography.bodySmall(
                                  color: AppColors.secondaryTeal,
                                ).copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
