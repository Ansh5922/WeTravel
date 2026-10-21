import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/we_travel_drawer.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../domain/entities/trip_suggestion.dart';
import '../widgets/group_idea_tile.dart';
import '../widgets/planning_readiness_card.dart';
import '../widgets/trip_bottom_nav_bar.dart';

/// "Trip Workspace" screen matching the WeTravel design screenshot.
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
  TripEntity? _trip;

  // ── Mock Initial Suggestions from Group ──────────────────────────────────
  late List<TripSuggestion> _suggestions;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<TripBloc>().state;
    if (currentState is TripDetailLoadedState && currentState.trip.id == widget.tripId) {
      _trip = currentState.trip;
    } else if (currentState is TripCreatedState && currentState.trip.id == widget.tripId) {
      _trip = currentState.trip;
    }

    if (widget.tripId.isNotEmpty && widget.tripId != 'goa-getaway') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TripBloc>().add(TripDetailsRequested(widget.tripId));
        }
      });
    }
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

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.trips);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        drawer: const WeTravelDrawer(),
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
      ),
    );
  }

  /// Main Workspace View matching the screenshot
  Widget _buildWorkspaceView(double topPadding) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripDetailLoadedState && state.trip.id == widget.tripId) {
          setState(() {
            _trip = state.trip;
          });
        } else if (state is TripCreatedState && state.trip.id == widget.tripId) {
          setState(() {
            _trip = state.trip;
          });
        }
      },
      builder: (context, state) {
        final trip = _trip ??
            (state is TripDetailLoadedState && state.trip.id == widget.tripId
                ? state.trip
                : null);

        final tripTitle = trip != null ? '${trip.name} - Workspace' : 'Trip Workspace';
        final coverUrl = trip?.coverImageUrl;

        final String dateRange;
        if (trip != null && trip.tripStartDate != null && trip.tripEndDate != null) {
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          final s = trip.tripStartDate!;
          final e = trip.tripEndDate!;
          dateRange = '${months[s.month - 1]} ${s.day}–${e.day}';
        } else {
          dateRange = 'Upcoming';
        }
        final memberCount = trip != null && trip.members.isNotEmpty ? trip.members.length : 1;

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
                    child: coverUrl != null && coverUrl.startsWith('http')
                        ? Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF004E64),
                              child: const Center(
                                child: Icon(Icons.beach_access, size: 60, color: Colors.white),
                              ),
                            ),
                          )
                        : Image.asset(
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
                          onPressed: _handleBack,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tripTitle,
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
                        const SizedBox(width: 4),
                        Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Open navigation menu',
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
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
                        dateRange: dateRange,
                        memberCount: memberCount,
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
  },
);
}

  /// View when switching to Itinerary or Expenses tabs
}
