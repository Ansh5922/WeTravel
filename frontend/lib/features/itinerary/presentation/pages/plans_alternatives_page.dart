import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';

import '../../../trips/presentation/widgets/invite_screen_decorations.dart';

class TripPlan {
  final String id;
  final String code; // e.g. "PLAN A"
  final String name; // e.g. "Relaxed Coast"
  final String matchBadge; // "High Match"
  final Color matchColor;
  final Color matchTextColor;
  final String description;
  final String budget;
  final String duration;
  final String placesCount;
  final List<String> highlights;
  final String imageUrl;
  final bool isMostPopular;

  const TripPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.matchBadge,
    required this.matchColor,
    required this.matchTextColor,
    required this.description,
    required this.budget,
    required this.duration,
    required this.placesCount,
    required this.highlights,
    required this.imageUrl,
    this.isMostPopular = false,
  });
}

/// "Plans / Alternatives" screen matching the WeTravel design screenshot.
/// Presents Plan A, B, and C with full photographic headers, match pills,
/// checklist features, interactive radio selection, and "Compare Plans" sticky CTA.
class PlansAlternativesPage extends StatefulWidget {
  final String tripId;

  const PlansAlternativesPage({
    super.key,
    required this.tripId,
  });

  @override
  State<PlansAlternativesPage> createState() => _PlansAlternativesPageState();
}

class _PlansAlternativesPageState extends State<PlansAlternativesPage> {
  String _selectedPlanId = 'plan_a';

  final List<TripPlan> _plans = const [
    TripPlan(
      id: 'plan_a',
      code: 'PLAN A',
      name: 'Relaxed Coast',
      matchBadge: 'High Match',
      matchColor: Color(0xFFDEF2F1),
      matchTextColor: Color(0xFF007791),
      description: 'Perfect for beach lovers and foodies.',
      budget: '₹23K',
      duration: '7 Days',
      placesCount: '4 Places',
      highlights: [
        'Beaches & sunset spots',
        'Local food experiences',
        'Leisurely pace',
      ],
      imageUrl: 'assets/images/sunset_beach_plan.jpg',
      isMostPopular: true,
    ),
    TripPlan(
      id: 'plan_b',
      code: 'PLAN B',
      name: 'Active Explorer',
      matchBadge: 'Moderate Match',
      matchColor: Color(0xFFFEF3C7),
      matchTextColor: Color(0xFF92400E),
      description: 'For adventure seekers and explorers.',
      budget: '₹28K',
      duration: '7 Days',
      placesCount: '5 Places',
      highlights: [
        'Water sports & adventure',
        'Hiking & nature trails',
        'Local markets',
      ],
      imageUrl: 'assets/images/coastal_cliffs_plan.jpg',
      isMostPopular: false,
    ),
    TripPlan(
      id: 'plan_c',
      code: 'PLAN C',
      name: 'Budget Mix',
      matchBadge: 'Good Match',
      matchColor: Color(0xFFFEF3C7),
      matchTextColor: Color(0xFFB45309),
      description: 'Best value with a mix of fun & relaxation.',
      budget: '₹20K',
      duration: '6 Days',
      placesCount: '4 Places',
      highlights: [
        'Affordable beach stays',
        'Scooter routes & street stalls',
        'Free scenic viewpoints',
      ],
      imageUrl: 'assets/images/palolem_beach.jpg',
      isMostPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 68,
              bottom: bottomPadding + 88,
              left: 18,
              right: 18,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ── Plan Cards ─────────────────────────────────────────
                ..._plans.map((plan) {
                  final isSelected = _selectedPlanId == plan.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPlanId = plan.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF007791) : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover Image Header with Badges
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                                  child: SizedBox(
                                    height: 140,
                                    width: double.infinity,
                                    child: Image.asset(
                                      plan.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFFDEF2F1),
                                        child: const Center(
                                          child: Icon(Icons.photo, color: Color(0xFF004E64)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (plan.isMostPopular)
                                  Positioned(
                                    top: 12,
                                    left: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'Most Popular',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF004E64),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Plan Content Body
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title + Match badge + Radio
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${plan.code} — ',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: const Color(0xFF004E64),
                                                ),
                                              ),
                                              TextSpan(
                                                text: plan.name,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF004E64),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: plan.matchColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          plan.matchBadge,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: plan.matchTextColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Radio selector
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF007791)
                                                : const Color(0xFFCBD5E1),
                                            width: 1.8,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.circle,
                                                  color: Color(0xFF007791),
                                                  size: 10,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.description,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Stats icons row
                                  Row(
                                    children: [
                                      _buildPlanStat(Icons.account_balance_wallet_outlined, plan.budget, 'Budget'),
                                      const SizedBox(width: 18),
                                      _buildPlanStat(Icons.alarm_rounded, plan.duration, 'Duration'),
                                      const SizedBox(width: 18),
                                      _buildPlanStat(Icons.place_outlined, plan.placesCount, 'Places'),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Highlights Checklist + View Plan button
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: plan.highlights.map((h) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_rounded,
                                                    size: 15,
                                                    color: Color(0xFF007791),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      h,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color: const Color(0xFF004E64),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          context.push(RouteNames.itineraryPath(widget.tripId));
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFF007791), width: 1.2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                        ),
                                        child: Text(
                                          'View Plan',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF007791),
                                          ),
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
                    ),
                  );
                }),
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
                  size: Size(MediaQuery.of(context).size.width, topPadding + 60),
                  painter: InviteHeaderPainter(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 4,
                    left: 10,
                    right: 12,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Plans / Alternatives',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom "Compare Plans" Button ──────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: bottomPadding > 0 ? bottomPadding : 16,
              ),
              color: const Color(0xFFFAF9F6),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(RouteNames.itineraryPath(widget.tripId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B), // Golden amber
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Compare Plans',
                        style: GoogleFonts.inter(
                          fontSize: 16,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF007791)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004E64),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
