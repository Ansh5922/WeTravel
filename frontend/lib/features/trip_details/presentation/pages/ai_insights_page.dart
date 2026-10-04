import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';

/// Custom wave painter for the AI Insights header — warm cream + golden dune
/// with dual-layer teal wave matching the screenshot's sand/wave aesthetic.
class _AiInsightsHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Teal base
    final tealPaint = Paint()
      ..color = const Color(0xFF004E64)
      ..style = PaintingStyle.fill;

    final baseWave = Path()
      ..lineTo(0, size.height - 30)
      ..cubicTo(
        size.width * 0.25,
        size.height - 48,
        size.width * 0.65,
        size.height - 10,
        size.width,
        size.height - 28,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(baseWave, tealPaint);

    // 2. Golden sand-dune accent on bottom right
    final goldPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..style = PaintingStyle.fill;

    final sandDune = Path()
      ..moveTo(size.width * 0.60, size.height - 38)
      ..cubicTo(
        size.width * 0.75,
        size.height - 36,
        size.width * 0.88,
        size.height - 54,
        size.width,
        size.height - 65,
      )
      ..lineTo(size.width, size.height - 48)
      ..cubicTo(
        size.width * 0.88,
        size.height - 34,
        size.width * 0.75,
        size.height - 28,
        size.width * 0.60,
        size.height - 38,
      )
      ..close();
    canvas.drawPath(sandDune, goldPaint);

    // 3. Lighter sand accent (higher up, thinner)
    final lightSandPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final sandDune2 = Path()
      ..moveTo(size.width * 0.80, size.height - 90)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height - 86,
        size.width,
        size.height - 96,
      )
      ..lineTo(size.width, size.height - 80)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height - 74,
        size.width * 0.80,
        size.height - 90,
      )
      ..close();
    canvas.drawPath(sandDune2, lightSandPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "AI Insights" screen matching the WeTravel design screenshot.
/// Displays AI-synthesized group preference summary, Group Travel Style selector,
/// Key Preferences checklist, and an interactive "Review Planning Readiness" CTA.
class AiInsightsPage extends StatefulWidget {
  final String tripId;

  const AiInsightsPage({
    super.key,
    required this.tripId,
  });

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  String _selectedTravelStyle = 'Relaxed';

  final List<String> _travelStyles = const ['Relaxed', 'Adventurous', 'Cultural'];

  final List<Map<String, dynamic>> _keyPreferences = [
    {'label': 'Beaches & water activities', 'checked': true},
    {'label': 'Good food & local cuisine', 'checked': true},
    {'label': 'Nature & scenic spots', 'checked': false},
    {'label': 'Comfortable stays', 'checked': true},
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0), // Warm cream matching screenshot
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 68,
              bottom: bottomPadding + 24,
              left: 18,
              right: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── 1. Group Preference Summary Card ──────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Golden circle with sparkle icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group Preference Summary',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF004E64),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Here's what we found from everyone's preferences, food choices and travel style.",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: const Color(0xFF007791),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 3-Column Stat Row
                      Row(
                        children: [
                          _buildStatChip(
                            icon: Icons.beach_access_rounded,
                            title: 'Beaches',
                            subtitle: 'Top choice',
                          ),
                          const SizedBox(width: 10),
                          _buildStatChip(
                            icon: Icons.restaurant_rounded,
                            title: 'Local Food',
                            subtitle: 'High priority',
                          ),
                          const SizedBox(width: 10),
                          _buildStatChip(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Budget',
                            subtitle: '₹20K – ₹30K',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // AI Insight Banner
                      InkWell(
                        onTap: () {
                          context.push(RouteNames.plansAlternativesPath(widget.tripId));
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB), // Warm amber cream
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                              width: 1.0,
                            ),
                          ),
                        child: Row(
                          children: [
                            // Lightbulb icon
                            const Icon(
                              Icons.lightbulb_rounded,
                              color: Color(0xFFF59E0B),
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI INSIGHT',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Schedule relaxed mornings and mix free beaches with one paid activity.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: const Color(0xFF92400E),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── 2. Group Travel Style Card ─────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDEF2F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.people_rounded,
                                color: Color(0xFF004E64),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Group Travel Style',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Style Pills
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _travelStyles.map((style) {
                          final isSelected = _selectedTravelStyle == style;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTravelStyle = style;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF59E0B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                style,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF004E64),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── 3. Key Preferences Card ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDEF2F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFF004E64),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Key Preferences',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Preference Checklist
                      ...List.generate(_keyPreferences.length, (index) {
                        final pref = _keyPreferences[index];
                        final isChecked = pref['checked'] as bool;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isChecked
                                        ? const Color(0xFF004E64)
                                        : const Color(0xFFCBD5E1),
                                    width: 1.8,
                                  ),
                                  color: isChecked
                                      ? Colors.transparent
                                      : Colors.transparent,
                                ),
                                child: isChecked
                                    ? const Center(
                                        child: Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Color(0xFF004E64),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                pref['label'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── 4. "Review Planning Readiness" CTA ────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push(RouteNames.plansAlternativesPath(widget.tripId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B), // Golden Amber
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Review Planning Readiness',
                          style: GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Color(0xFF004E64),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Top Header ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    topPadding + 60,
                  ),
                  painter: _AiInsightsHeaderPainter(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 4,
                    left: 10,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Insights',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // "Powered by AI" badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFDE68A),
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Powered by AI',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF004E64), size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004E64),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF007791),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
