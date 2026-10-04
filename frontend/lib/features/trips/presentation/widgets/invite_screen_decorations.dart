import 'package:flutter/material.dart';

/// Custom decorative header for the Invite Members screen featuring
/// deep teal background, golden accent swoosh at top right, and organic bottom wave.
class InviteHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Teal Base
    final tealPaint = Paint()
      ..color = const Color(0xFF004E64)
      ..style = PaintingStyle.fill;

    final baseWave = Path()
      ..lineTo(0, size.height - 35)
      ..cubicTo(
        size.width * 0.20,
        size.height - 50,
        size.width * 0.60,
        size.height - 10,
        size.width,
        size.height - 30,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(baseWave, tealPaint);

    // 2. Golden-Yellow Accent Swoosh on the right
    final goldPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final goldSwoosh = Path()
      ..moveTo(size.width * 0.65, size.height - 40)
      ..cubicTo(
        size.width * 0.78,
        size.height - 38,
        size.width * 0.90,
        size.height - 55,
        size.width,
        size.height - 68,
      )
      ..lineTo(size.width, size.height - 45)
      ..cubicTo(
        size.width * 0.90,
        size.height - 35,
        size.width * 0.78,
        size.height - 30,
        size.width * 0.65,
        size.height - 40,
      )
      ..close();

    canvas.drawPath(goldSwoosh, goldPaint);

    // Subtle golden corner accent near top right
    final cornerAccent = Path()
      ..moveTo(size.width * 0.86, size.height - 90)
      ..quadraticBezierTo(
        size.width * 0.94,
        size.height - 86,
        size.width,
        size.height - 95,
      )
      ..lineTo(size.width, size.height - 80)
      ..quadraticBezierTo(
        size.width * 0.93,
        size.height - 75,
        size.width * 0.86,
        size.height - 90,
      )
      ..close();

    canvas.drawPath(cornerAccent, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom decorative painter rendering tropical botanical leaves on the left
/// and curved dashed trail with location pin on the right.
class InviteBottomDecorator extends StatelessWidget {
  const InviteBottomDecorator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Stack(
        children: [
          // Left Tropical Leaves
          Positioned(
            left: -8,
            bottom: -6,
            child: CustomPaint(
              size: const Size(80, 60),
              painter: _TropicalLeavesPainter(),
            ),
          ),

          // Right Dotted Map Trail
          Positioned(
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: const Size(180, 50),
              painter: _BottomDashedTrailPainter(),
            ),
          ),

          // Right Yellow Location Pin
          const Positioned(
            right: 12,
            bottom: 12,
            child: Icon(
              Icons.location_on,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _TropicalLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = const Color(0xFF004E64)
      ..style = PaintingStyle.fill;

    final yellowPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    // Teal leaf 1
    final leaf1 = Path()
      ..moveTo(10, size.height)
      ..quadraticBezierTo(18, size.height - 35, 34, size.height - 50)
      ..quadraticBezierTo(28, size.height - 25, 20, size.height)
      ..close();
    canvas.drawPath(leaf1, tealPaint);

    // Teal leaf 2
    final leaf2 = Path()
      ..moveTo(22, size.height)
      ..quadraticBezierTo(38, size.height - 30, 58, size.height - 36)
      ..quadraticBezierTo(42, size.height - 18, 30, size.height)
      ..close();
    canvas.drawPath(leaf2, tealPaint);

    // Yellow accent leaf
    final leaf3 = Path()
      ..moveTo(8, size.height)
      ..quadraticBezierTo(30, size.height - 15, 45, size.height - 12)
      ..quadraticBezierTo(28, size.height - 8, 12, size.height)
      ..close();
    canvas.drawPath(leaf3, yellowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomDashedTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.90);
    path.cubicTo(
      size.width * 0.40,
      size.height * 0.70,
      size.width * 0.75,
      size.height * 0.20,
      size.width - 24,
      size.height * 0.45,
    );

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paper airplane origami icon matching the screenshot share card
class OrigamiAirplaneIcon extends StatelessWidget {
  final double size;

  const OrigamiAirplaneIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OrigamiAirplanePainter(),
      ),
    );
  }
}

class _OrigamiAirplanePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = const Color(0xFF005F73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final goldFill = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;

    // Upper wing filled with yellow/gold
    final upperWing = Path()
      ..moveTo(size.width * 0.15, size.height * 0.65)
      ..lineTo(size.width * 0.85, size.height * 0.15)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..close();
    canvas.drawPath(upperWing, goldFill);

    // Airplane outline
    final plane = Path()
      ..moveTo(size.width * 0.15, size.height * 0.65)
      ..lineTo(size.width * 0.85, size.height * 0.15)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..lineTo(size.width * 0.40, size.height * 0.55)
      ..close();
    canvas.drawPath(plane, tealPaint);

    // Center fold line
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.40, size.height * 0.55),
      tealPaint..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
