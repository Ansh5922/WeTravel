import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_scenic_decorations.dart';

/// Single-page high-impact onboarding screen.
/// - Strictly non-scrollable: all components fit within one viewport via proportional sizing.
/// - Subtitle on one line with no carousel dots.
/// - Central traveler photograph in organic blob.
/// - Responsive leaf petals and continuous dotted trail that scales across phone sizes.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        body: Stack(
          children: [
            // ── 0. Bottom-Left Foliage & Dune Corner Decoration ───────────
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: AuthScenicBottomDecoration(
                  height: 70,
                  showDottedTrail: false,
                  leafLeftOffset: -28,
                ),
              ),
            ),

            SafeArea(
              top: false,
              bottom: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. Top Scenic Wavy Banner (~25% screen height) ────────
                  SizedBox(
                    height: (size.height * 0.25).clamp(160.0, 215.0),
                    width: double.infinity,
                    child: ClipPath(
                      clipper: _TopWaveClipper(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryDeepTeal,
                                  Color(0xFF1A7A7A),
                                  Color(0xFF2AA1A1),
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/hero_coast.jpg',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.18),
                                    Colors.transparent,
                                    AppColors.backgroundWarm.withValues(alpha: 0.40),
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 2. Main Content fills remaining space with no scrolling ─
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          // Brand logo
                          const WeTravelLogo(iconSize: 26, fontSize: 22),

                          const SizedBox(height: 8),

                          // Editorial Headline
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discover\nYour Next',
                                style: GoogleFonts.inter(
                                  fontSize: size.width < 370 ? 25 : 29,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDeepTeal,
                                  letterSpacing: -0.6,
                                  height: 1.15,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Adventure',
                                    style: GoogleFonts.inter(
                                      fontSize: size.width < 370 ? 25 : 29,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accentWarmYellow,
                                      letterSpacing: -0.6,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const SunIcon(size: 26),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Subtitle
                          Text(
                            'Plan Explore & Experience Together',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // ── 3. Central Traveler Blob + Foliage & Trail ─────
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final w = constraints.maxWidth;
                                final h = constraints.maxHeight;

                                final blobWidth = math.min(w * 0.65, 225.0);
                                final blobHeight = math.min(h * 0.70, 138.0);
                                final blobLeft = (w - blobWidth) / 2;
                                final blobTop = math.max((h - blobHeight) * 0.70, 6.0);

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Golden Sun Disc peaking behind top-left of blob
                                    Positioned(
                                      left: blobLeft + 4,
                                      top: blobTop - 14,
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5A623),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),

                                    // Full-width continuous dotted flight trail extending past screen boundaries
                                    Positioned(
                                      left: -24.0,
                                      right: -24.0,
                                      top: 0,
                                      bottom: 0,
                                      child: CustomPaint(
                                        painter: _FullWidthTrailPainter(),
                                      ),
                                    ),

                                    // Location pin on the right of the blob
                                    Positioned(
                                      right: math.max(blobLeft - 22, 4),
                                      top: blobTop + blobHeight * 0.38,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppColors.primaryDeepTeal,
                                        size: 22,
                                      ),
                                    ),

                                    // Flying Airplane on trail
                                    Positioned(
                                      right: blobLeft + 2,
                                      top: math.max(blobTop - 22, 2),
                                      child: Transform.rotate(
                                        angle: 0.45,
                                        child: const Icon(
                                          Icons.flight_rounded,
                                          color: AppColors.accentWarmYellow,
                                          size: 22,
                                        ),
                                      ),
                                    ),

                                    // Traveler blob — centered, compact and tasteful
                                    Positioned(
                                      left: blobLeft,
                                      top: blobTop,
                                      width: blobWidth,
                                      height: blobHeight,
                                      child: const _TravelerBlob(),
                                    ),

                                    // Botanical leaves — bottom-left hugging blob corner
                                    Positioned(
                                      left: math.max(blobLeft - 18, -4),
                                      bottom: math.max(h - (blobTop + blobHeight) - 8, -6),
                                      child: const BotanicalLeavesCluster(
                                        size: Size(82, 75),
                                      ),
                                    ),

                                    // Botanical leaves — bottom-right hugging blob corner
                                    Positioned(
                                      right: math.max(blobLeft - 12, -4),
                                      bottom: math.max(h - (blobTop + blobHeight) - 4, -4),
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(-1, 1, 1),
                                        child: const BotanicalLeavesCluster(
                                          size: Size(68, 62),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ── 4. Feature Badges with Vertical Dividers ───────
                          Row(
                            children: [
                              const _FeatureBadge(
                                icon: Icons.explore_outlined,
                                label: 'Plan\nSmart',
                              ),
                              Container(
                                width: 1,
                                height: 38,
                                color: AppColors.borderWarm.withValues(alpha: 0.7),
                              ),
                              const _FeatureBadge(
                                icon: Icons.interests_rounded,
                                label: 'Manage\nMultiple\nInterests',
                              ),
                              Container(
                                width: 1,
                                height: 38,
                                color: AppColors.borderWarm.withValues(alpha: 0.7),
                              ),
                              const _FeatureBadge(
                                icon: Icons.public_rounded,
                                label: 'Explore\nThe World',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── 5. CTA Button ─────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => context.go(RouteNames.signup),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentWarmYellow,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor:
                                    AppColors.accentWarmYellow.withValues(alpha: 0.38),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 20, color: Colors.white),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Footer
                          Center(
                            child: Wrap(
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
                          ),

                          SizedBox(height: size.height > 700 ? 28 : 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Traveler Blob
// ─────────────────────────────────────────────────────────────────────────────

class _TravelerBlob extends StatelessWidget {
  const _TravelerBlob();

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(56),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(54),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeepTeal.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          'assets/images/onboarding_traveler.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0.35, -0.15),
          errorBuilder: (_, _, _) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDeepTeal, Color(0xFF2AA1A1)],
              ),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, size: 56, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature Badge
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryDeepTeal, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeepTeal,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Wave Clipper
// ─────────────────────────────────────────────────────────────────────────────

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 38)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height - 70,
        size.width * 0.73,
        size.height - 24,
      )
      ..quadraticBezierTo(
        size.width * 0.89,
        size.height + 2,
        size.width,
        size.height - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-Width Responsive Dotted Trail Painter
// Uses proportional coordinates so trail always spans end-to-end on any device.
// ─────────────────────────────────────────────────────────────────────────────

class _FullWidthTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentWarmYellow.withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Cubic bezier: starts completely off-screen left → sweeps across center → exits off-screen right
    final path = Path()
      ..moveTo(-30.0, size.height * 0.88)
      ..cubicTo(
        size.width * 0.20, size.height * 0.28,   // ctrl-1
        size.width * 0.65, size.height * 0.02,   // ctrl-2
        size.width + 30.0, size.height * 0.30,   // exits off-screen right
      );

    _drawDashed(canvas, path, paint, dashLen: 6.0, gapLen: 4.5);
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLen,
    required double gapLen,
  }) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dashLen), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
