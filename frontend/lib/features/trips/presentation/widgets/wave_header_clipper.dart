import 'package:flutter/material.dart';

/// Smooth asymmetrical wave clipper for the top scenic header edge.
class WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Starts higher up on the left
    path.lineTo(0, size.height - 40);

    // First crest & dip: rises gently on the left, dips towards the center-left
    path.cubicTo(
      size.width * 0.12,
      size.height - 48,
      size.width * 0.28,
      size.height - 10,
      size.width * 0.50,
      size.height - 12,
    );

    // Gently flattens out towards the right
    path.cubicTo(
      size.width * 0.72,
      size.height - 14,
      size.width * 0.88,
      size.height - 15,
      size.width,
      size.height - 15,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
