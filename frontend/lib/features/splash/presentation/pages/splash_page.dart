import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_scenic_decorations.dart';

/// Simple yet elegant WeTravel Splash Screen.
///
/// Plain deep teal background, official origami paper plane logo,
/// and bold "WeTravel" typography in white.
class SplashPage extends StatefulWidget {
  final Duration? autoNavigateDelay;

  const SplashPage({
    super.key,
    this.autoNavigateDelay = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Timed transition to Onboarding
    if (widget.autoNavigateDelay != null) {
      _navigationTimer = Timer(widget.autoNavigateDelay!, () {
        if (mounted) {
          context.go(RouteNames.onboarding);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache onboarding images during splash animation so onboarding loads with zero lag
    precacheImage(const AssetImage('assets/images/hero_coast.jpg'), context);
    precacheImage(const AssetImage('assets/images/onboarding_traveler.jpg'), context);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDeepTeal,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Official App Logo ─────────────────────────────────────
                const CustomPaint(
                  size: Size(84, 72),
                  painter: PaperPlaneLogoPainter(
                    primaryColor: AppColors.accentWarmYellow,
                    secondaryColor: AppColors.secondaryTeal,
                  ),
                ),

                const SizedBox(height: 22),

                // ── "WeTravel" Title in Pure White ────────────────────────
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
