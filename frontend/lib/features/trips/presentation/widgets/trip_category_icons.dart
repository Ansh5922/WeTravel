import 'package:flutter/material.dart';

/// Custom pixel-precise icons matching the design screenshot:
/// - Palm tree for Vacation
/// - Triangle mountain with snow line for Adventure
/// - Fork & Knife for Food
/// - Classical Greek Temple for Cultural

class PalmTreeIcon extends StatelessWidget {
  final Color color;
  final double size;

  const PalmTreeIcon({
    super.key,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PalmTreePainter(color: color),
      ),
    );
  }
}

class _PalmTreePainter extends CustomPainter {
  final Color color;

  _PalmTreePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Trunk (slight natural curve)
    final trunk = Path();
    final startX = size.width * 0.48;
    final startY = size.height * 0.42;
    trunk.moveTo(startX, startY);
    trunk.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.68,
      size.width * 0.48,
      size.height * 0.94,
    );
    canvas.drawPath(trunk, paint..strokeWidth = 2.8);

    // 2. Palm Fronds (radiating curved leaves)
    final leafPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left far leaf
    final l1 = Path();
    l1.moveTo(startX, startY);
    l1.cubicTo(
      size.width * 0.32,
      size.height * 0.28,
      size.width * 0.15,
      size.height * 0.38,
      size.width * 0.12,
      size.height * 0.52,
    );
    canvas.drawPath(l1, leafPaint);

    // Left high leaf
    final l2 = Path();
    l2.moveTo(startX, startY);
    l2.cubicTo(
      size.width * 0.35,
      size.height * 0.18,
      size.width * 0.22,
      size.height * 0.20,
      size.width * 0.20,
      size.height * 0.36,
    );
    canvas.drawPath(l2, leafPaint);

    // Top center leaf
    final l3 = Path();
    l3.moveTo(startX, startY);
    l3.cubicTo(
      size.width * 0.44,
      size.height * 0.12,
      size.width * 0.54,
      size.height * 0.12,
      size.width * 0.50,
      size.height * 0.28,
    );
    canvas.drawPath(l3, leafPaint);

    // Right high leaf
    final l4 = Path();
    l4.moveTo(startX, startY);
    l4.cubicTo(
      size.width * 0.62,
      size.height * 0.18,
      size.width * 0.76,
      size.height * 0.20,
      size.width * 0.78,
      size.height * 0.36,
    );
    canvas.drawPath(l4, leafPaint);

    // Right far leaf
    final l5 = Path();
    l5.moveTo(startX, startY);
    l5.cubicTo(
      size.width * 0.65,
      size.height * 0.28,
      size.width * 0.82,
      size.height * 0.38,
      size.width * 0.86,
      size.height * 0.52,
    );
    canvas.drawPath(l5, leafPaint);

    // Small coconuts cluster at center
    canvas.drawCircle(Offset(startX - 2.5, startY + 2), 2.0, fillPaint);
    canvas.drawCircle(Offset(startX + 2.5, startY + 2), 2.0, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _PalmTreePainter oldDelegate) =>
      oldDelegate.color != color;
}

class AdventureMountainIcon extends StatelessWidget {
  final Color color;
  final double size;

  const AdventureMountainIcon({
    super.key,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AdventureMountainPainter(color: color),
      ),
    );
  }
}

class _AdventureMountainPainter extends CustomPainter {
  final Color color;

  _AdventureMountainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Main mountain triangle
    final peak = Offset(size.width * 0.50, size.height * 0.18);
    final leftBottom = Offset(size.width * 0.16, size.height * 0.84);
    final rightBottom = Offset(size.width * 0.84, size.height * 0.84);

    final mountain = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(rightBottom.dx, rightBottom.dy)
      ..lineTo(leftBottom.dx, leftBottom.dy)
      ..close();

    canvas.drawPath(mountain, stroke);

    // Snow peak cap zig-zag line inside
    final snowLine = Path()
      ..moveTo(size.width * 0.38, size.height * 0.44)
      ..lineTo(size.width * 0.46, size.height * 0.48)
      ..lineTo(size.width * 0.52, size.height * 0.42)
      ..lineTo(size.width * 0.58, size.height * 0.48)
      ..lineTo(size.width * 0.62, size.height * 0.44);

    canvas.drawPath(snowLine, stroke..strokeWidth = 2.0);

    // Small interior rock circle or compass element
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.68),
      2.8,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AdventureMountainPainter oldDelegate) =>
      oldDelegate.color != color;
}

class DiningForkKnifeIcon extends StatelessWidget {
  final Color color;
  final double size;

  const DiningForkKnifeIcon({
    super.key,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiningForkKnifePainter(color: color),
      ),
    );
  }
}

class _DiningForkKnifePainter extends CustomPainter {
  final Color color;

  _DiningForkKnifePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Fork (Left)
    final forkX = size.width * 0.36;
    // Handle
    canvas.drawLine(
      Offset(forkX, size.height * 0.48),
      Offset(forkX, size.height * 0.86),
      stroke..strokeWidth = 2.4,
    );
    // Base of tines
    final forkBase = Path()
      ..moveTo(forkX - 6, size.height * 0.22)
      ..lineTo(forkX - 6, size.height * 0.40)
      ..quadraticBezierTo(forkX, size.height * 0.50, forkX + 6, size.height * 0.40)
      ..lineTo(forkX + 6, size.height * 0.22);
    canvas.drawPath(forkBase, stroke..strokeWidth = 2.0);
    // Center tine
    canvas.drawLine(
      Offset(forkX, size.height * 0.22),
      Offset(forkX, size.height * 0.44),
      stroke..strokeWidth = 2.0,
    );

    // Knife (Right)
    final knifeX = size.width * 0.64;
    // Handle
    canvas.drawLine(
      Offset(knifeX, size.height * 0.50),
      Offset(knifeX, size.height * 0.86),
      stroke..strokeWidth = 2.4,
    );
    // Blade
    final blade = Path()
      ..moveTo(knifeX, size.height * 0.50)
      ..lineTo(knifeX, size.height * 0.22)
      ..quadraticBezierTo(knifeX + 6, size.height * 0.26, knifeX + 6, size.height * 0.42)
      ..lineTo(knifeX, size.height * 0.50);
    canvas.drawPath(blade, fill);
  }

  @override
  bool shouldRepaint(covariant _DiningForkKnifePainter oldDelegate) =>
      oldDelegate.color != color;
}

class TempleIcon extends StatelessWidget {
  final Color color;
  final double size;

  const TempleIcon({
    super.key,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TemplePainter(color: color),
      ),
    );
  }
}

class _TemplePainter extends CustomPainter {
  final Color color;

  _TemplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Pediment (Triangular roof)
    final roof = Path()
      ..moveTo(size.width * 0.18, size.height * 0.34)
      ..lineTo(size.width * 0.50, size.height * 0.20)
      ..lineTo(size.width * 0.82, size.height * 0.34)
      ..close();
    canvas.drawPath(roof, fill);

    // Entablature (horizontal bar below roof)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          size.width * 0.16,
          size.height * 0.35,
          size.width * 0.84,
          size.height * 0.39,
        ),
        const Radius.circular(1),
      ),
      fill,
    );

    // 4 Columns
    const cols = 4;
    final startColX = size.width * 0.23;
    final endColX = size.width * 0.77;
    final step = (endColX - startColX) / (cols - 1);
    for (int i = 0; i < cols; i++) {
      final cx = startColX + i * step;
      canvas.drawLine(
        Offset(cx, size.height * 0.40),
        Offset(cx, size.height * 0.76),
        stroke..strokeWidth = 2.2,
      );
    }

    // Base (Steps)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          size.width * 0.14,
          size.height * 0.77,
          size.width * 0.86,
          size.height * 0.84,
        ),
        const Radius.circular(1.5),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TemplePainter oldDelegate) =>
      oldDelegate.color != color;
}
