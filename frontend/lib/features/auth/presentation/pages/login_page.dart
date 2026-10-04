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

/// WeTravel Login Screen.
/// Clean, minimal, editorial design connected to AuthController.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'pandeysuyash@gmail.com');
  final _passwordController = TextEditingController(text: 'Suyash@2004');

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final authState = ref.read(authControllerProvider);
    if (authState.isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _emailController.text = 'pandeysuyash@gmail.com';
                          _passwordController.text = 'Suyash@2004';
                        });
                      },
                      child: const AuthHeader(
                        title: 'Welcome back.',
                        subtitle: 'Your next journey starts here.',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

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
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // ── Email Field ──────────────────────────────────────────
                    AuthTextField(
                      label: 'Email',
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

                    const SizedBox(height: AppSpacing.lg),

                    // ── Password Field with Visibility Toggle ────────────────
                    AuthTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Primary Action: "Log in" ──────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onLogin,
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
                                'Log in',
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
                        onPressed: isLoading
                            ? null
                            : () => ref.read(authControllerProvider.notifier).googleSignIn(),
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

                    // ── Secondary Navigation: "Sign up" ──────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTypography.bodySmall(
                            color: AppColors.textSecondary,
                          ).copyWith(fontSize: 13.5),
                        ),
                        TextButton(
                          onPressed: () => context.go(RouteNames.signup),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign up',
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
