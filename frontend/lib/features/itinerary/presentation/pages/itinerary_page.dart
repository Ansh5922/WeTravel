import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';

class ItineraryItem {
  final String title;
  final String time;
  final String cost;
  final IconData icon;
  final Color iconBg;

  const ItineraryItem({
    required this.title,
    required this.time,
    required this.cost,
    required this.icon,
    required this.iconBg,
  });
}

/// "Final Itinerary" screen matching the WeTravel design screenshot.
/// Features:
/// - Hero banner header with back arrow & title
/// - "Goa Weekend Escape" card with "Finalized" status pill
/// - Subtabs: "Itinerary", "Expenses", "Members"
/// - Day 1 timeline with sequential events, times, and costs
/// - "View Map" action
/// - Bottom bar with "View Booking Links" CTA + Share icon button
class ItineraryPage extends StatefulWidget {
  final String tripId;

  const ItineraryPage({
    super.key,
    required this.tripId,
  });

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = const ['Itinerary', 'Expenses', 'Members'];

  final List<ItineraryItem> _day1Events = const [
    ItineraryItem(
      title: 'Calangute Beach',
      time: '8:00 AM – 10:00 AM',
      cost: 'Free',
      icon: Icons.beach_access_rounded,
      iconBg: Color(0xFF007791),
    ),
    ItineraryItem(
      title: 'Lunch at Brittos',
      time: '12:30 PM – 1:30 PM',
      cost: '₹800',
      icon: Icons.restaurant_rounded,
      iconBg: Color(0xFFF59E0B),
    ),
    ItineraryItem(
      title: 'Aguada Fort',
      time: '3:00 PM – 5:00 PM',
      cost: '₹200',
      icon: Icons.fort_rounded,
      iconBg: Color(0xFF004E64),
    ),
    ItineraryItem(
      title: 'Dinner at Fisherman\'s Wharf',
      time: '8:00 PM – 10:00 PM',
      cost: '₹1,000',
      icon: Icons.dinner_dining_rounded,
      iconBg: Color(0xFF0D9488),
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
              bottom: bottomPadding + 88,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Hero Image Banner Header ────────────────────────
                Stack(
                  children: [
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/goa_itinerary_banner.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF004E64),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Back button & Title
                    Positioned(
                      top: topPadding + 6,
                      left: 10,
                      right: 16,
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
                            'Final Itinerary',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Curved bottom transition
                    Positioned(
                      bottom: -1,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAF9F6),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── 2. Trip Info Card & Subtabs ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Goa Weekend Escape + Finalized Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Goa Weekend Escape',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '12 Oct - 15 Oct 2026  •  4 days',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF007791),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEF2F1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Finalized',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF004E64),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Tabs: Itinerary, Expenses, Members
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                          ),
                        ),
                        child: Row(
                          children: List.generate(_tabs.length, (index) {
                            final isSelected = _selectedTabIndex == index;
                            return GestureDetector(
                              onTap: () {
                                if (index == 1) {
                                  // Navigate to Expenses
                                  context.push(RouteNames.expensesPath(widget.tripId));
                                } else {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isSelected ? const Color(0xFF004E64) : Colors.transparent,
                                      width: 2.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _tabs[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF004E64) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── 3. Day 1 Timeline Container ────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day 1 — 12 Oct (Mon)',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF004E64),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Timeline items
                            ...List.generate(_day1Events.length, (index) {
                              final event = _day1Events[index];
                              final isLast = index == _day1Events.length - 1;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline node column
                                  Column(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: event.iconBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            event.icon,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        Container(
                                          width: 2,
                                          height: 38,
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Event Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 22),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF004E64),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${event.time}  •  ${event.cost}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            // View Map Button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Opening Day 1 route on interactive map...'),
                                      backgroundColor: Color(0xFF004E64),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFF8FAFC),
                                ),
                                child: Text(
                                  'View Map',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom Actions Bar ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 10,
                bottom: bottomPadding > 0 ? bottomPadding : 16,
              ),
              color: const Color(0xFFFAF9F6),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening partner bookings for hotels & activities...'),
                              backgroundColor: Color(0xFF004E64),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B), // Golden amber
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'View Booking Links',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Share Button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF004E64), width: 1.5),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Color(0xFF004E64),
                        size: 20,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Itinerary link copied to clipboard!'),
                            backgroundColor: Color(0xFF004E64),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
