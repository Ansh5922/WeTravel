import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Production-ready custom painter rendering the signature WeTravel header:
/// - Deep Teal background (#004E64)
/// - Organic sweeping bottom curve
/// - Warm golden accent swoosh (#F59E0B) on the bottom-right
/// - Subtle golden corner accent at the top-right
class WeTravelHeaderPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  const WeTravelHeaderPainter({
    this.primaryColor = const Color(0xFF004E64),
    this.accentColor = const Color(0xFFF59E0B),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(clipRect);

    // 1. Deep Teal Curved Base
    final tealPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final baseWave = Path()
      ..lineTo(0, size.height - 28)
      ..cubicTo(
        size.width * 0.22,
        size.height - 44,
        size.width * 0.58,
        size.height - 8,
        size.width,
        size.height - 24,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(baseWave, tealPaint);

    // 2. Golden-Yellow Accent Swoosh on the right
    final goldPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final goldSwoosh = Path()
      ..moveTo(size.width * 0.62, size.height - 32)
      ..cubicTo(
        size.width * 0.76,
        size.height - 30,
        size.width * 0.88,
        size.height - 46,
        size.width,
        size.height - 56,
      )
      ..lineTo(size.width, size.height - 38)
      ..cubicTo(
        size.width * 0.88,
        size.height - 28,
        size.width * 0.76,
        size.height - 22,
        size.width * 0.62,
        size.height - 32,
      )
      ..close();

    canvas.drawPath(goldSwoosh, goldPaint);

    // 3. Subtle golden corner accent near top right
    final cornerAccent = Path()
      ..moveTo(size.width * 0.86, size.height - 76)
      ..quadraticBezierTo(
        size.width * 0.94,
        size.height - 72,
        size.width,
        size.height - 80,
      )
      ..lineTo(size.width, size.height - 68)
      ..quadraticBezierTo(
        size.width * 0.93,
        size.height - 63,
        size.width * 0.86,
        size.height - 76,
      )
      ..close();

    canvas.drawPath(cornerAccent, goldPaint);
  }

  @override
  bool shouldRepaint(covariant WeTravelHeaderPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.accentColor != accentColor;
}

/// A unified, highly reusable screen header across primary tabs (My Trips, Inbox, Profile).
///
/// Features:
/// - Signature WeTravel curved deep teal background with warm gold wave accents
/// - Automatic handling of status bar padding via [MediaQuery]
/// - Clean typography matching the design system
/// - Flexible leading slot (e.g. drawer hamburger icon or back button)
/// - Flexible trailing actions slot
/// - Optional bottom slot (e.g. for search bars, filter chips, or custom controls)
class WeTravelScreenHeader extends StatelessWidget {
  /// The prominent title displayed in the header.
  final String title;

  /// Optional secondary text displayed below the title.
  final String? subtitle;

  /// Optional widget displayed to the left of the title (e.g. back button or drawer menu).
  final Widget? leading;

  /// If true and [leading] is null, renders the standard drawer hamburger icon.
  final bool showMenuButton;

  /// Callback when [showMenuButton] hamburger icon is pressed. Defaults to opening the drawer.
  final VoidCallback? onMenuTap;

  /// Trailing action widgets displayed on the top-right.
  final List<Widget>? actions;

  /// Optional widget placed in the bottom section of the header (e.g. a search bar).
  final Widget? bottom;

  /// Additional vertical height to reserve for the [bottom] widget.
  final double bottomHeight;

  /// Base content height (excluding status bar and [bottomHeight]). Default is 88.
  final double baseHeight;

  const WeTravelScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.showMenuButton = false,
    this.onMenuTap,
    this.actions,
    this.bottom,
    this.bottomHeight = 0,
    this.baseHeight = 88,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = topPadding + baseHeight + bottomHeight;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── 1. Curved Painter Background ────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, totalHeight),
              painter: const WeTravelHeaderPainter(),
            ),
          ),

          // ── 2. Header Content Layout ────────────────────────────────────
          Positioned(
            top: topPadding + 4,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title + Navigation Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading Widget or Menu Button
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ] else if (showMenuButton) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Open navigation menu',
                        onPressed: onMenuTap ??
                            () => Scaffold.of(context).openDrawer(),
                      ),
                      const SizedBox(width: 14),
                    ],

                    // Title & Subtitle Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Trailing Actions
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                    ],
                  ],
                ),

                // Bottom widget (e.g. search bar)
                if (bottom != null) ...[
                  const SizedBox(height: 8),
                  bottom!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
