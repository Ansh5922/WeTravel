import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

/// WeTravel Signup Screen.
/// Collects registration fields and connects directly to AuthController.
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
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
    final authState = ref.read(authControllerProvider);
    if (authState.isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();

      ref.read(authControllerProvider.notifier).signup(
            _emailController.text.trim(),
            _passwordController.text,
            _usernameController.text.trim(),
            fullName.isNotEmpty ? fullName : null,
            phone.isNotEmpty ? phone : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state transitions (one-time side-effects)
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go(RouteNames.home);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

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
                      title: 'Start your journey.',
                      subtitle:
                          'Create your account and start planning together.',
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Error Banner ─────────────────────────────────────────
                    if (authState is AuthError) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: AppRadius.card,
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authState.message,
                                style: AppTypography.bodySmall(
                                  color: Colors.red.shade900,
                                ).copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // ── Username Field (Required) ────────────────────────────
                    AuthTextField(
                      label: 'Username *',
                      hintText: 'e.g. wanderer_99',
                      helperText:
                          '3–50 characters, letters, numbers and underscore',
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      validator: AuthValidators.validateUsername,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Email Field (Required) ───────────────────────────────
                    AuthTextField(
                      label: 'Email *',
                      hintText: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      validator: AuthValidators.validateEmail,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Password Field (Required) ────────────────────────────
                    AuthTextField(
                      label: 'Password *',
                      hintText: 'At least 8 characters',
                      helperText: 'At least 8 characters',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        tooltip:
                            _obscurePassword ? 'Show password' : 'Hide password',
                      ),
                      validator: AuthValidators.validatePassword,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Full Name Field (Optional) ───────────────────────────
                    AuthTextField(
                      label: 'Full name (optional)',
                      hintText: 'e.g. Alex Mercer',
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Phone Field (Optional) ───────────────────────────────
                    AuthTextField(
                      label: 'Phone number (optional)',
                      hintText: '+91 98765 43210',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onCreateAccount(),
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ── Primary Action: "Create account" ─────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onCreateAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDeepTeal,
                          foregroundColor: AppColors.surfaceWhite,
                          disabledBackgroundColor:
                              AppColors.primaryDeepTeal.withValues(alpha: 0.6),
                          disabledForegroundColor:
                              AppColors.surfaceWhite.withValues(alpha: 0.8),
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
  }
}
