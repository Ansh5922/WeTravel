import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../../trips/domain/entities/trip_entity.dart';

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
  String? _selectedTravelStyle;

  final List<String> _travelStyles = const ['Relaxed', 'Adventurous', 'Cultural', 'Balanced'];

  @override
  void initState() {
    super.initState();
    final isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv && widget.tripId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TripBloc>().add(TripDetailsRequested(widget.tripId));
          context.read<TripBloc>().add(GroupConsensusRequested(widget.tripId));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        GroupConsensusEntity? consensus;
        TripEntity? trip;
        if (state is TripDetailLoadedState) {
          consensus = state.consensus;
          trip = state.trip;
        }

        final dominantStyle = consensus?.dominantTravelStyle ?? 'Relaxed';
        final currentStyle = _selectedTravelStyle ?? dominantStyle;
        final pace = consensus?.majorityPace ?? 'Moderate';
        final budget = consensus?.budgetDisplay ?? '₹2,500 / day';

        final List<Map<String, dynamic>> keyPreferences = [
          {'label': 'Dominant Style: $dominantStyle', 'checked': true},
          {'label': 'Pace Preference: $pace pace', 'checked': true},
          {'label': 'Budget Goal: $budget', 'checked': true},
          if (consensus != null && consensus.dietaryRestrictions.isNotEmpty)
            {
              'label': 'Dietary: ${consensus.dietaryRestrictions.join(", ")}',
              'checked': true
            },
          if (consensus != null && consensus.climateSensitivities.isNotEmpty)
            {
              'label': 'Climate: ${consensus.climateSensitivities.join(", ")}',
              'checked': true
            },
          {'label': 'Good food & authentic local spots', 'checked': true},
        ];

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFFAF9F6),
            body: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: topPadding + 82,
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
                                      trip != null
                                          ? "AI synthesized insights for ${trip.name} from all members' travel preferences."
                                          : "Here's what we found from everyone's preferences, food choices and travel style.",
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
                                icon: Icons.explore_rounded,
                                title: dominantStyle,
                                subtitle: 'Travel Style',
                              ),
                              const SizedBox(width: 10),
                              _buildStatChip(
                                icon: Icons.speed_rounded,
                                title: pace,
                                subtitle: 'Trip Pace',
                              ),
                              const SizedBox(width: 10),
                              _buildStatChip(
                                icon: Icons.account_balance_wallet_rounded,
                                title: budget,
                                subtitle: 'Avg Budget',
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
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
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
                                          'Group leans towards a $dominantStyle style at a $pace pace. We balance popular spots with authentic hidden gems.',
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
                              final isSelected = currentStyle.toLowerCase() == style.toLowerCase();
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

                    // ── 3. Key Preferences Checklist ──────────────────────
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
                                    Icons.tune_rounded,
                                    color: Color(0xFF004E64),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Consensus Highlights',
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
                          ...List.generate(keyPreferences.length, (index) {
                            final pref = keyPreferences[index];
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
                                  Expanded(
                                    child: Text(
                                      pref['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF004E64),
                                      ),
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

                    // ── 4. CTA Button ────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(RouteNames.plansAlternativesPath(widget.tripId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View AI Itinerary Plans',
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

              // ── Fixed Top Curvy Teal Header ─────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: topPadding + 74,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _AiInsightsHeaderPainter(),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 6,
                            right: 16,
                            top: 4,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => context.pop(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI Group Consensus',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A).withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFFFDE68A),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'AI Powered',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
      },
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
          color: const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF007791)),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004E64),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom wave painter for the AI Group Consensus header — rich deep teal with golden sand-dune accents.
class _AiInsightsHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Teal base
    final tealPaint = Paint()
      ..color = const Color(0xFF004E64)
      ..style = PaintingStyle.fill;

    final baseWave = Path()
      ..lineTo(0, size.height - 24)
      ..cubicTo(
        size.width * 0.28,
        size.height - 38,
        size.width * 0.65,
        size.height - 8,
        size.width,
        size.height - 22,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(baseWave, tealPaint);

    // 2. Golden sand-dune accent on bottom right
    final goldPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..style = PaintingStyle.fill;

    final sandDune = Path()
      ..moveTo(size.width * 0.60, size.height - 30)
      ..cubicTo(
        size.width * 0.75,
        size.height - 28,
        size.width * 0.88,
        size.height - 44,
        size.width,
        size.height - 52,
      )
      ..lineTo(size.width, size.height - 38)
      ..cubicTo(
        size.width * 0.88,
        size.height - 26,
        size.width * 0.75,
        size.height - 20,
        size.width * 0.60,
        size.height - 30,
      )
      ..close();
    canvas.drawPath(sandDune, goldPaint);

    // 3. Lighter sand accent
    final lightSandPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final sandDune2 = Path()
      ..moveTo(size.width * 0.80, size.height - 70)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height - 66,
        size.width,
        size.height - 76,
      )
      ..lineTo(size.width, size.height - 62)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height - 56,
        size.width * 0.80,
        size.height - 70,
      )
      ..close();
    canvas.drawPath(sandDune2, lightSandPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
