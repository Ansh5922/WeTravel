import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

/// Minimal, high-craft travel emblem for WeTravel.
/// Depicts an abstract journey: convergent paths meeting at an AI-optimized destination node.
class TravelEmblem extends StatelessWidget {
  final double size;
  final double animationProgress;

  const TravelEmblem({
    super.key,
    this.size = 84.0,
    this.animationProgress = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderWarm,
          width: 1.5,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.62,
          height: size * 0.62,
          child: CustomPaint(
            painter: _TravelRoutePainter(
              progress: animationProgress,
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelRoutePainter extends CustomPainter {
  final double progress;

  _TravelRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle background grid / meridian arc
    final meridianPaint = Paint()
      ..color = AppColors.borderWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.46, meridianPaint);

    // 2. Primary Route (Deep Teal)
    final primaryPath = Path();
    primaryPath.moveTo(w * 0.18, h * 0.82);
    primaryPath.cubicTo(
      w * 0.25,
      h * 0.40,
      w * 0.55,
      h * 0.65,
      w * 0.76,
      h * 0.24,
    );

    final primaryRoutePaint = Paint()
      ..color = AppColors.primaryDeepTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(primaryPath, primaryRoutePaint);

    // 3. Collaborative Synced Route (Secondary Teal)
    final secondaryPath = Path();
    secondaryPath.moveTo(w * 0.28, h * 0.88);
    secondaryPath.cubicTo(
      w * 0.38,
      h * 0.55,
      w * 0.58,
      h * 0.48,
      w * 0.76,
      h * 0.24,
    );

    final secondaryRoutePaint = Paint()
      ..color = AppColors.secondaryTeal.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(secondaryPath, secondaryRoutePaint);

    // 4. Starting origin points
    final originPaint = Paint()
      ..color = AppColors.secondaryTeal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.18, h * 0.82), 2.2, originPaint);
    canvas.drawCircle(Offset(w * 0.28, h * 0.88), 1.8, originPaint);

    // 5. Destination Waypoint (Warm Accent Yellow #EE9B00)
    final destCenter = Offset(w * 0.76, h * 0.24);

    // Pulse ring
    final pulsePaint = Paint()
      ..color = AppColors.accentWarmYellow.withValues(alpha: 0.25 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(destCenter, 7.0 + (progress * 2.0), pulsePaint);

    // Solid waypoint node
    final destPaint = Paint()
      ..color = AppColors.accentWarmYellow
      ..style = PaintingStyle.fill;
    canvas.drawCircle(destCenter, 4.0, destPaint);

    // Inner white star point / center
    final corePaint = Paint()
      ..color = AppColors.surfaceWhite
      ..style = PaintingStyle.fill;
    canvas.drawCircle(destCenter, 1.4, corePaint);
  }

  @override
  bool shouldRepaint(covariant _TravelRoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
