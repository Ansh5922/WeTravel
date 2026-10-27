// WeTravel Signup Screen matching the exact reference design.
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

/// Pixel-perfect WeTravel Signup Screen following the reference design.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isLoading) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions and Privacy Policy.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final fullNameText = _fullNameController.text.trim();
      bloc.add(
        AuthSignupRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          fullName: fullNameText.isNotEmpty ? fullNameText : null,
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
          if (state.isFirstTimeUser) {
            context.go(RouteNames.preferences);
          } else {
            context.go(RouteNames.home);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

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
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 16),

                                      // ── 1. Top Brand Bar ──────────────────────────────
                                      const AuthTopBar(showBackButton: false),

                                      const SizedBox(height: 20),

                          // ── 2. Editorial Headline & Subtitle ──────────────
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Create Your Account',
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
                            'Join our community and start\nexploring the world.',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── 3. Error Banner ───────────────────────────────
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
                            const SizedBox(height: 18),
                          ],

                          // ── 4. Full Name Field (Required) ─────────────────
                          TextFormField(
                            controller: _fullNameController,
                            keyboardType: TextInputType.name,
                            autofillHints: const [AutofillHints.name],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: AuthValidators.validateFullName,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Full name *',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── 5. Username Field (Required) ──────────────────
                          TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: const [AutofillHints.newUsername],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: AuthValidators.validateUsername,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Username *',
                              prefixIcon: Icons.alternate_email_rounded,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── 6. Email Field (Required) ─────────────────────
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: AuthValidators.validateEmail,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Email address *',
                              prefixIcon: Icons.mail_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── 7. Password Field (Required) ──────────────────
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: const [AutofillHints.newPassword],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: AuthValidators.validatePassword,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Password *',
                              prefixIcon: Icons.lock_outline_rounded,
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
                          ),

                          const SizedBox(height: 14),

                          // ── 8. Confirm Password Field (Required) ──────────
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: const [AutofillHints.newPassword],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (val) =>
                                AuthValidators.validateConfirmPassword(
                              val,
                              _passwordController.text,
                            ),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onCreateAccount(),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _buildInputDecoration(
                              hintText: 'Confirm password *',
                              prefixIcon: Icons.lock_reset_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── 9. Password Helper Banner (Teal Container) ───
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F1F1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.secondaryTeal
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: AppColors.secondaryTeal,
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Password must be at least 8 characters and include a number.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryDeepTeal,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── 10. Terms & Conditions Checkbox ───────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (val) {
                                    setState(() {
                                      _agreedToTerms = val ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primaryDeepTeal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.primaryDeepTeal,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      'I agree to the ',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Terms & Conditions',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: AppColors.primaryDeepTeal,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Privacy Policy',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        color: AppColors.primaryDeepTeal,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── 11. Primary CTA: Create Account Button ────────
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onCreateAccount,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Create Account',
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

                          const SizedBox(height: 18),

                          // ── 12. OR Divider ────────────────────────────────
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppColors.borderWarm),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                child: Text(
                                  'or',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.borderWarm),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── 13. Google Sign Up Button ─────────────────────
                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: isLoading ? null : _onGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.borderWarm,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGoogleGLogo(),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sign up with Google',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── 14. Secondary Navigation: "Log in" ────────────
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go(RouteNames.login),
                                child: Text(
                                  'Log in',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: AppColors.primaryDeepTeal,
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 14.5,
        color: AppColors.textMuted,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.primaryDeepTeal,
        size: 20,
      ),
      suffixIcon: suffixIcon,
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

  Widget _buildGoogleGLogo() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBlue = Paint()..color = const Color(0xFF4285F4);
    final paintRed = Paint()..color = const Color(0xFFEA4335);
    final paintYellow = Paint()..color = const Color(0xFFFBBC05);
    final paintGreen = Paint()..color = const Color(0xFF34A853);

    final rect = Rect.fromLTWH(0, 0, w, h);

    final pathBlue = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w, h * 0.5)
      ..arcTo(rect, 0, -1.2, false)
      ..close();
    canvas.drawPath(pathBlue, paintBlue);

    final pathRed = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..arcTo(rect, -1.2, -1.9, false)
      ..close();
    canvas.drawPath(pathRed, paintRed);

    final pathYellow = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..arcTo(rect, -3.1, -1.5, false)
      ..close();
    canvas.drawPath(pathYellow, paintYellow);

    final pathGreen = Path()
      ..moveTo(w * 0.5, h * 0.5)
      ..arcTo(rect, 1.5, -1.5, false)
      ..close();
    canvas.drawPath(pathGreen, paintGreen);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.28, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
