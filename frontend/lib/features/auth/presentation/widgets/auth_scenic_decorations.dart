import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Reusable paper plane brand logo with bold "WeTravel" title.
class WeTravelLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final MainAxisAlignment alignment;

  const WeTravelLogo({
    super.key,
    this.iconSize = 26,
    this.fontSize = 22,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        // App's official origami paper plane logo
        CustomPaint(
          size: Size(iconSize * 1.15, iconSize),
          painter: const PaperPlaneLogoPainter(),
        ),
        const SizedBox(width: 10),
        Text(
          'WeTravel',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDeepTeal,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for WeTravel's official origami paper plane logo
/// featuring golden yellow wings and a deep teal underbelly keel.
class PaperPlaneLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  const PaperPlaneLogoPainter({
    this.primaryColor = AppColors.accentWarmYellow,
    this.secondaryColor = AppColors.primaryDeepTeal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Teal underbelly / center fold
    final keelDarkPaint = Paint()
      ..color = const Color(0xFF004554)
      ..style = PaintingStyle.fill;

    final keelPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Center keel fold and underbelly
    final keelPath = Path()
      ..moveTo(w * 0.95, h * 0.08)
      ..lineTo(w * 0.42, h * 0.46)
      ..lineTo(w * 0.34, h * 0.96)
      ..lineTo(w * 0.27, h * 0.68)
      ..close();
    canvas.drawPath(keelPath, keelDarkPaint);

    final keelTopPath = Path()
      ..moveTo(w * 0.95, h * 0.08)
      ..lineTo(w * 0.49, h * 0.52)
      ..lineTo(w * 0.34, h * 0.96)
      ..lineTo(w * 0.42, h * 0.46)
      ..close();
    canvas.drawPath(keelTopPath, keelPaint);

    // 2. Left Wing (Top golden yellow wing)
    final leftWingPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final leftWingPath = Path()
      ..moveTo(w * 0.95, h * 0.08)
      ..lineTo(w * 0.03, h * 0.40)
      ..quadraticBezierTo(w * 0.0, h * 0.43, w * 0.04, h * 0.45)
      ..lineTo(w * 0.28, h * 0.53)
      ..lineTo(w * 0.44, h * 0.45)
      ..close();
    canvas.drawPath(leftWingPath, leftWingPaint);

    // 3. Right Wing (Bottom golden yellow wing)
    final rightWingPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final rightWingPath = Path()
      ..moveTo(w * 0.95, h * 0.08)
      ..lineTo(w * 0.49, h * 0.52)
      ..lineTo(w * 0.69, h * 0.90)
      ..quadraticBezierTo(w * 0.72, h * 0.92, w * 0.74, h * 0.86)
      ..close();
    canvas.drawPath(rightWingPath, rightWingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized warm sun icon with radiant rays matching the reference designs.
class SunIcon extends StatelessWidget {
  final double size;
  final Color color;

  const SunIcon({
    super.key,
    this.size = 22,
    this.color = AppColors.accentWarmYellow,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SunPainter(color: color),
    );
  }
}

class _SunPainter extends CustomPainter {
  final Color color;

  _SunPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.24;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, radius, circlePaint);

    final rayPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    const rayCount = 8;
    final startDist = radius + 2.5;
    final endDist = radius + 5.5;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final x1 = center.dx + startDist * math.cos(angle);
      final y1 = center.dy + startDist * math.sin(angle);
      final x2 = center.dx + endDist * math.cos(angle);
      final y2 = center.dy + endDist * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Standardized top bar for Auth screens (Login, Signup, Forgot Password).
/// Guarantees exact same height, padding, and WeTravel branding across all screens.
class AuthTopBar extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const AuthTopBar({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryDeepTeal,
                size: 24,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 4),
          ],
          const WeTravelLogo(
            iconSize: 26,
            fontSize: 22,
          ),
        ],
      ),
    );
  }
}

/// Scenic bottom decoration containing botanical foliage, soft sand dune,
/// and dynamic full-width dotted travel trail that never discontinues.
class AuthScenicBottomDecoration extends StatelessWidget {
  final double height;
  final bool showDottedTrail;
  final double leafLeftOffset;

  const AuthScenicBottomDecoration({
    super.key,
    this.height = 110,
    this.showDottedTrail = true,
    this.leafLeftOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Soft organic sand dune background wave across full width
            Positioned.fill(
              child: CustomPaint(
                painter: _BottomDunePainter(),
              ),
            ),

            // 2. Full-width responsive dotted flight trail + destination pin
            if (showDottedTrail)
              Positioned.fill(
                child: CustomPaint(
                  painter: _DottedFlightTrailPainter(),
                ),
              ),

            // 3. Botanical leaves cluster on bottom-left flush to bottom edge
            Positioned(
              left: leafLeftOffset,
              bottom: 0,
              child: BotanicalLeavesCluster(
                size: Size(130, height * 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft sand-dune wave spanning the entire screen width.
class _BottomDunePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF3ECE0).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.28,
        size.width * 0.68,
        size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.62,
        size.width,
        size.height * 0.52,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cluster of botanical leaves in brand colors (deep teal, secondary teal, golden yellow).
class BotanicalLeavesCluster extends StatelessWidget {
  final Size size;

  const BotanicalLeavesCluster({
    super.key,
    this.size = const Size(120, 100),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _BotanicalLeavesPainter(),
    );
  }
}

class _BotanicalLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Leaf 1: Warm Golden Yellow (large, pointing up-left)
    _drawLeaf(
      canvas: canvas,
      base: Offset(w * 0.18, h * 0.98),
      tip: Offset(w * 0.12, h * 0.08),
      controlOffset: w * 0.16,
      color: AppColors.accentWarmYellow,
    );

    // Leaf 2: Primary Deep Teal (large, pointing upright)
    _drawLeaf(
      canvas: canvas,
      base: Offset(w * 0.28, h * 0.98),
      tip: Offset(w * 0.48, h * 0.18),
      controlOffset: w * 0.18,
      color: AppColors.primaryDeepTeal,
    );

    // Leaf 3: Secondary Teal (pointing up-right)
    _drawLeaf(
      canvas: canvas,
      base: Offset(w * 0.32, h * 0.98),
      tip: Offset(w * 0.78, h * 0.40),
      controlOffset: w * 0.15,
      color: AppColors.secondaryTeal,
    );

    // Leaf 4: Accent Warm Yellow (small accent leaf pointing lower right)
    _drawLeaf(
      canvas: canvas,
      base: Offset(w * 0.36, h * 0.99),
      tip: Offset(w * 0.94, h * 0.72),
      controlOffset: w * 0.12,
      color: AppColors.accentWarmYellow,
    );

    // Leaf 5: Soft Teal inner accent leaf
    _drawLeaf(
      canvas: canvas,
      base: Offset(w * 0.15, h * 0.98),
      tip: Offset(w * 0.28, h * 0.52),
      controlOffset: w * 0.10,
      color: const Color(0xFF1E8278),
    );
  }

  void _drawLeaf({
    required Canvas canvas,
    required Offset base,
    required Offset tip,
    required double controlOffset,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dx = tip.dx - base.dx;
    final dy = tip.dy - base.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final normalX = -dy / dist;
    final normalY = dx / dist;

    final mid = Offset((base.dx + tip.dx) / 2, (base.dy + tip.dy) / 2);
    final c1 = Offset(
      mid.dx + normalX * controlOffset,
      mid.dy + normalY * controlOffset,
    );
    final c2 = Offset(
      mid.dx - normalX * controlOffset,
      mid.dy - normalY * controlOffset,
    );

    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(c1.dx, c1.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(c2.dx, c2.dy, base.dx, base.dy)
      ..close();

    canvas.drawPath(path, paint);

    // Spine
    final spinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(base, tip, spinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dynamic, responsive dotted flight path trail that exceeds screen edges
/// on both the left and right, sweeping continuously across the sand dune.
class _DottedFlightTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentWarmYellow
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Path starts completely off-screen on the left (-30.0),
    // swoops gracefully across the sand dunes, passes the destination pin,
    // and exits completely off-screen on the right (size.width + 30.0).
    final p0 = Offset(-30.0, size.height * 0.82);
    final p1 = Offset(size.width * 0.25, size.height * 0.92);
    final p2 = Offset(size.width * 0.68, size.height * 0.15);
    final p3 = Offset(size.width + 30.0, size.height * 0.32);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    // Draw dashed line spanning past the screen boundaries
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashLength = 6.0;
      const dashSpace = 4.5;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          math.min(distance + dashLength, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }

    // 2. Draw destination pin at a prominent position along the trail (near the crest)
    const t = 0.80;
    final it = 1.0 - t;
    final pinX = it * it * it * p0.dx +
        3 * it * it * t * p1.dx +
        3 * it * t * t * p2.dx +
        t * t * t * p3.dx;
    final pinY = it * it * it * p0.dy +
        3 * it * it * t * p1.dy +
        3 * it * t * t * p2.dy +
        t * t * t * p3.dy;

    final pinCenter = Offset(pinX, pinY - 8);
    const pinRadius = 6.5;

    final pinPaint = Paint()
      ..color = AppColors.primaryDeepTeal
      ..style = PaintingStyle.fill;

    // Pin circle head
    canvas.drawCircle(pinCenter, pinRadius, pinPaint);

    // Pin pointer triangle
    final tipPath = Path()
      ..moveTo(pinCenter.dx - pinRadius * 0.82, pinCenter.dy + 2)
      ..lineTo(pinX, pinY)
      ..lineTo(pinCenter.dx + pinRadius * 0.82, pinCenter.dy + 2)
      ..close();
    canvas.drawPath(tipPath, pinPaint);

    // Inner white dot
    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 2.4, innerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Miniature trail painter for the ForgotPassword envelope graphic
class _EnvelopeTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentWarmYellow
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.9,
        size.height * 0.5,
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashLength = 4.0;
      const dashSpace = 3.5;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          math.min(distance + dashLength, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Central illustration for the Forgot Password screen:
/// Envelope with golden paper plane taking flight, surrounded by botanical leaves and dotted trail.
class ForgotPasswordIllustration extends StatelessWidget {
  const ForgotPasswordIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 190,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft mint circular background badge
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFD4EDE5).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),

            // Dotted flight trail sweeping across
            Positioned(
              right: 0,
              top: 50,
              child: CustomPaint(
                size: const Size(100, 40),
                painter: _EnvelopeTrailPainter(),
              ),
            ),

            // Map pin on the trail
            const Positioned(
              right: 12,
              top: 56,
              child: Icon(
                Icons.location_on,
                color: AppColors.primaryDeepTeal,
                size: 16,
              ),
            ),

            // Botanical leaves on left of envelope
            const Positioned(
              left: 10,
              bottom: 15,
              child: BotanicalLeavesCluster(size: Size(55, 55)),
            ),

            // The Envelope & Letter & Paper Plane
            Positioned(
              bottom: 25,
              child: SizedBox(
                width: 100,
                height: 75,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // White Letter / Card inside envelope
                    Positioned(
                      top: 4,
                      child: Container(
                        width: 76,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          // Little paper plane on the letter
                          child: Transform.rotate(
                            angle: -0.2,
                            child: const CustomPaint(
                              size: Size(22, 16),
                              painter: null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Envelope Front Body (Teal with open flap)
                    Positioned(
                      bottom: 0,
                      child: CustomPaint(
                        size: const Size(96, 56),
                        painter: _EnvelopeBodyPainter(),
                      ),
                    ),

                    // Flying Official Paper Plane hovering above
                    Positioned(
                      top: 14,
                      child: const CustomPaint(
                        size: Size(26, 22),
                        painter: PaperPlaneLogoPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the envelope body with pocket folds.
class _EnvelopeBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Main envelope body
    final bodyPaint = Paint()
      ..color = AppColors.primaryDeepTeal
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(4, 0)
      ..lineTo(w - 4, 0)
      ..quadraticBezierTo(w, 0, w, 4)
      ..lineTo(w, h - 4)
      ..quadraticBezierTo(w, h, w - 4, h)
      ..lineTo(4, h)
      ..quadraticBezierTo(0, h, 0, h - 4)
      ..lineTo(0, 4)
      ..quadraticBezierTo(0, 0, 4, 0)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Envelope pocket fold triangles
    final pocketPaint = Paint()
      ..color = const Color(0xFF004D5E)
      ..style = PaintingStyle.fill;

    // Left triangle
    final leftFold = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.5, h * 0.6)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftFold, pocketPaint);

    // Right triangle
    final rightFold = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.5, h * 0.6)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(rightFold, pocketPaint);

    // Bottom triangle
    final bottomPaint = Paint()
      ..color = const Color(0xFF003D4A)
      ..style = PaintingStyle.fill;
    final bottomFold = Path()
      ..moveTo(0, h)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(bottomFold, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
