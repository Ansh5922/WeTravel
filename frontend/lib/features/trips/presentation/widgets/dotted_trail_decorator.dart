import 'package:flutter/material.dart';

/// Decorative dotted map route trail ending with a teal location pin marker.
class DottedTrailDecorator extends StatelessWidget {
  const DottedTrailDecorator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          CustomPaint(
            size: const Size(double.infinity, 38),
            painter: _DottedTrailPainter(),
          ),
          const Positioned(
            right: 0,
            top: 6,
            child: Icon(
              Icons.location_on,
              color: Color(0xFF005F73),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.45, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.15,
      size.width - 24,
      size.height * 0.45,
    );

    // Draw dashed path
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
