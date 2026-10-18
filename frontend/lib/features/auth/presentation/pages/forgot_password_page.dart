// WeTravel Forgot Password Screen matching the exact reference design.
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

/// Pixel-perfect WeTravel Forgot Password Screen following the reference design.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      bloc.add(
        AuthForgotPasswordRequested(
          email: _emailController.text.trim(),
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

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: AppColors.backgroundWarm,
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
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
                                            'Forgot Password?',
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
                                        'No worries! Enter your email address\nand we’ll send you a reset link.',
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

                                      // ── 4. Form or Sent Confirmation ───────────────────
                                      if (isSent)
                                        _buildSuccessView(context, state)
                                      else
                                        _buildFormView(context, state, isLoading),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 16),

                            // ── 5. Full-Width Bottom Scenic Decoration ─────────
                            const AuthScenicBottomDecoration(height: 110),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }

  Widget _buildFormView(BuildContext context, AuthState state, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Error Banner ─────────────────────────────────────────────
          if (state is AuthErrorState) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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
                      state.message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Email Input Field ────────────────────────────────────────
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
            decoration: InputDecoration(
              hintText: 'Email address',
              hintStyle: GoogleFonts.inter(
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
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
            ),
          ),

          const SizedBox(height: 22),

          // ── Primary CTA: Send Reset Link Button ──────────────────────
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send Reset Link',
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

          // ── Footer: Enhanced Back to Login Button ────────────────────
          Center(
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
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
      BuildContext context, AuthPasswordResetSentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            children: [
              const TextSpan(text: 'We sent a password reset link to\n'),
              TextSpan(
                text: state.email,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(text: '.\nPlease check your inbox and spam folder.'),
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
                  'Back to Login',
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
}
