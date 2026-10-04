import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/trip_suggestion.dart';
import '../widgets/group_idea_tile.dart';
import '../widgets/planning_readiness_card.dart';
import '../widgets/trip_bottom_nav_bar.dart';

/// "Goa Weekend - Workspace" screen matching the WeTravel design screenshot.
/// Features a scenic tropical hero header, FLAGSHIP badge, planning readiness tracker,
/// AI Group Insight banner, collaborative ideas list with approvals, "+ Add Suggestion" CTA,
/// and trip-level bottom navigation (Workspace, Itinerary, Expenses).
class TripDetailsPage extends StatefulWidget {
  final String tripId;

  const TripDetailsPage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  int _currentTabIndex = 0;

  // ── Mock Initial Suggestions from Group ──────────────────────────────────
  late List<TripSuggestion> _suggestions;

  @override
  void initState() {
    super.initState();
    _suggestions = [
      const TripSuggestion(
        id: 'sugg_1',
        title: 'Sunset cruise',
        estimatedCost: 1200,
        approvalsCount: 3,
        totalMembers: 4,
        commentsCount: 6,
        imageUrl: 'assets/images/sunset_cruise.jpg',
        isApprovedByMe: true,
      ),
      const TripSuggestion(
        id: 'sugg_2',
        title: 'Beach shack dinner',
        estimatedCost: 800,
        approvalsCount: 4,
        totalMembers: 4,
        commentsCount: 4,
        imageUrl: 'assets/images/beach_dinner.jpg',
        isApprovedByMe: true,
      ),
      const TripSuggestion(
        id: 'sugg_3',
        title: 'Local markets',
        estimatedCost: 500,
        approvalsCount: 2,
        totalMembers: 4,
        commentsCount: 2,
        imageUrl: 'assets/images/local_markets.jpg',
        isApprovedByMe: true,
      ),
    ];
  }

  void _toggleApproval(int index) {
    setState(() {
      final item = _suggestions[index];
      final newApproved = !item.isApprovedByMe;
      final newCount = newApproved
          ? item.approvalsCount + 1
          : (item.approvalsCount > 0 ? item.approvalsCount - 1 : 0);

      _suggestions[index] = item.copyWith(
        isApprovedByMe: newApproved,
        approvalsCount: newCount,
      );
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _suggestions[index].isApprovedByMe
              ? 'Upvoted "${_suggestions[index].title}"'
              : 'Removed upvote for "${_suggestions[index].title}"',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF004E64),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showInsightModal() {
    context.push(RouteNames.aiInsightsPath(widget.tripId));
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      bottomNavigationBar: TripBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          if (index == 1) {
            context.push(RouteNames.itineraryPath(widget.tripId));
          } else if (index == 2) {
            context.push(RouteNames.expensesPath(widget.tripId));
          } else {
            setState(() {
              _currentTabIndex = index;
            });
          }
        },
      ),
      body: _buildWorkspaceView(topPadding),
    );
  }

  /// Main Workspace View matching the screenshot
  Widget _buildWorkspaceView(double topPadding) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Hero Scenic Header with Top Bar ───────────────────────
          Stack(
            children: [
              // Hero Photo
              SizedBox(
                width: double.infinity,
                height: topPadding + 180,
                child: Image.asset(
                  'assets/images/trip_goa.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF004E64),
                    child: const Center(
                      child: Icon(Icons.beach_access, size: 60, color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Top Gradient for contrast
              Container(
                width: double.infinity,
                height: topPadding + 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Navigation Bar
              Padding(
                padding: EdgeInsets.only(
                  top: topPadding + 6,
                  left: 10,
                  right: 16,
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
                    Expanded(
                      child: Text(
                        'Goa Weekend - Workspace',
                        style: GoogleFonts.inter(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // FLAGSHIP Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'FLAGSHIP',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── 2. Content Body ──────────────────────────────────────────
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Planning Readiness Card
                  PlanningReadinessCard(
                    dateRange: 'Oct 12–15',
                    memberCount: 4,
                    readinessProgress: 0.75,
                    onInsightTap: _showInsightModal,
                  ),
                  const SizedBox(height: 20),

                  // Ideas from Group Section Header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'Ideas from Group',
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF004E64),
                      ),
                    ),
                  ),

                  // Group Ideas Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
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
                      children: List.generate(_suggestions.length, (index) {
                        final isLast = index == _suggestions.length - 1;
                        return Column(
                          children: [
                            GroupIdeaTile(
                              suggestion: _suggestions[index],
                              onToggleApproval: () => _toggleApproval(index),
                              onTap: () {
                                context.push(
                                  RouteNames.suggestionDetailPath(widget.tripId),
                                  extra: _suggestions[index],
                                );
                              },
                            ),
                            if (!isLast)
                              const Divider(
                                color: Color(0xFFF1F5F9),
                                height: 1,
                                indent: 90,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // "+ Add Suggestion" Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newSuggestion = await context.push<TripSuggestion>(
                          RouteNames.addSuggestionPath(widget.tripId),
                        );
                        if (newSuggestion != null) {
                          setState(() {
                            _suggestions.add(newSuggestion);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004E64),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Add Suggestion',
                            style: GoogleFonts.inter(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
    );
  }

  /// View when switching to Itinerary or Expenses tabs
}
