// WeTravel Forgot & Reset Password Screen supporting OTP and New Password flow.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_scenic_decorations.dart';
import '../widgets/auth_validators.dart';

/// WeTravel Forgot & Reset Password Screen with 6-digit OTP verification.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;

    if (_emailFormKey.currentState?.validate() ?? false) {
      bloc.add(
        AuthForgotPasswordRequested(
          email: _emailController.text.trim(),
        ),
      );
    }
  }

  void _onResetPassword() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;

    if (_resetFormKey.currentState?.validate() ?? false) {
      bloc.add(
        AuthResetPasswordRequested(
          email: _emailController.text.trim(),
          otp: _otpController.text.trim(),
          newPassword: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        final isLoading = state.isLoading;
        final isSent = state is AuthPasswordResetSentState;
        final isSuccess = state is AuthPasswordResetSuccessState;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.black,
          ),
          child: Scaffold(
            backgroundColor: AppColors.backgroundWarm,
            body: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 440),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 16),

                                      // ── 1. Top Brand Bar with Navigation Back Button ──
                                      AuthTopBar(
                                        showBackButton: true,
                                        onBack: () => context.go(RouteNames.login),
                                      ),

                                      const SizedBox(height: 20),

                                      // ── 2. Editorial Headline & Subtitle ──────────────
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            isSuccess
                                                ? 'Password Reset!'
                                                : isSent
                                                    ? 'Enter Reset Code'
                                                    : 'Forgot Password?',
                                            style: GoogleFonts.inter(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryDeepTeal,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const SunIcon(size: 24),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        isSuccess
                                            ? 'Your password has been changed. You can now log into your account.'
                                            : isSent
                                                ? 'Enter the 6-digit verification code sent to your email and set your new password.'
                                                : 'No worries! Enter your email address and we’ll send you a 6-digit verification code.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // ── 3. Central Illustration ────────────────────────
                                      const ForgotPasswordIllustration(),

                                      const SizedBox(height: 18),

                                      // ── 4. Form or Confirmation ───────────────────
                                      if (isSuccess)
                                        _buildSuccessView(context, state)
                                      else if (isSent)
                                        _buildResetPasswordForm(context, state, isLoading)
                                      else
                                        _buildEmailFormView(context, state, isLoading),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.only(top: 24.0),
                              child: AuthScenicBottomDecoration(height: 110),
                            ),
                          ],
                        ),
                      ),
                    );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Initial email submission form view
  Widget _buildEmailFormView(BuildContext context, AuthState state, bool isLoading) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state is AuthErrorState) ...[
            _buildErrorBanner(state.message),
            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: AuthValidators.validateEmail,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSendResetLink(),
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(
              hint: 'Email address',
              icon: Icons.mail_outline_rounded,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onSendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentWarmYellow,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send Reset Code',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),

          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  /// OTP & New Password form view
  Widget _buildResetPasswordForm(
    BuildContext context,
    AuthPasswordResetSentState state,
    bool isLoading,
  ) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryDeepTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryDeepTeal.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primaryDeepTeal,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Code sent to ${_emailController.text.trim()}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDeepTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── OTP Field ───────────────────────────────────────────────
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v == null || v.trim().length != 6) {
                return 'Please enter the 6-digit code sent to your email.';
              }
              return null;
            },
            style: GoogleFonts.inter(
              fontSize: 18,
              letterSpacing: 4.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: _inputDecoration(
              hint: '6-digit OTP Code',
              icon: Icons.pin_rounded,
            ),
          ),

          const SizedBox(height: 14),

          // ── New Password Field ─────────────────────────────────────
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: AuthValidators.validatePassword,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(
              hint: 'New password (min 8 characters)',
              icon: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Confirm Password Field ─────────────────────────────────
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(
              hint: 'Confirm new password',
              icon: Icons.lock_reset_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ── Reset Password CTA ─────────────────────────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentWarmYellow,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Reset Password',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_rounded,
                          size: 19,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Resend or try different email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Didn\'t receive the code? ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: isLoading ? null : _onSendResetLink,
                child: Text(
                  'Resend',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildBackToLoginButton(),
        ],
      ),
    );
  }

  /// Success view after password is fully reset
  Widget _buildSuccessView(BuildContext context, AuthPasswordResetSuccessState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF81C784)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 48,
              ),
              const SizedBox(height: 10),
              Text(
                'Password Reset Complete!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentWarmYellow,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Log In Now',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(14),
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
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => context.go(RouteNames.login),
        icon: const Icon(
          Icons.arrow_back_rounded,
          size: 17,
          color: AppColors.primaryDeepTeal,
        ),
        label: Text(
          'Back to Login',
          style: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDeepTeal,
            letterSpacing: 0.1,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.primaryDeepTeal.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14.5,
        color: AppColors.textMuted,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.primaryDeepTeal,
        size: 20,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.borderWarm,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.borderWarm,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryDeepTeal,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
    );
  }
}
