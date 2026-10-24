import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../trips/presentation/widgets/join_trip_dialog.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_action_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_sticky_top_bar.dart';
import '../widgets/home_trip_card.dart';

/// Primary authenticated Home screen displaying inspirational hero banner,
/// interactive floating search, quick trip actions, and dynamic trips list
/// powered by [HomeBloc] with real backend data, live search, and status filtering.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  String _activeStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Fetch initial trips from backend after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeBloc>().add(const HomeFetchRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<HomeBloc>().add(HomeSearchQueryChanged(query));
  }

  void _onClearSearchAndFilters() {
    setState(() {
      _activeStatusFilter = 'All';
      _searchController.clear();
    });
    context.read<HomeBloc>().add(const HomeFilterStatusChanged('All'));
    context.read<HomeBloc>().add(const HomeSearchQueryChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body with Pull-to-Refresh ─────────────────────────
          RefreshIndicator(
            color: const Color(0xFF0D9488),
            backgroundColor: Colors.white,
            displacement: 90,
            onRefresh: () async {
              final homeBloc = context.read<HomeBloc>();
              homeBloc.add(HomeFetchRequested(
                statusFilter: _activeStatusFilter == 'All'
                    ? null
                    : _activeStatusFilter.toLowerCase(),
              ));
              await homeBloc.stream.firstWhere(
                (state) => state is! HomeLoadingState,
              );
            },
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Scenic Hero Banner with Overlapping Search Bar ─────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const HomeHeader(
                          showTopBar: false,
                        ),

                        // Floating Search Bar overlapping banner bottom
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: -24,
                          child: BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (prev, curr) =>
                                prev.runtimeType != curr.runtimeType ||
                                (curr is HomeLoadedState &&
                                    prev is HomeLoadedState &&
                                    (prev.activeStatusFilter !=
                                            curr.activeStatusFilter ||
                                        prev.searchQuery != curr.searchQuery)),
                            builder: (context, state) {
                              final hasFilter = state is HomeLoadedState &&
                                  state.activeStatusFilter != 'All';
                              return HomeSearchBar(
                                controller: _searchController,
                                hasActiveFilter: hasFilter,
                                onChanged: _onSearchChanged,
                                onFilterTap: () => _showFilterSheet(context),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Spacer to accommodate floating search bar overlap
                    const SizedBox(height: 42),

                    // ── Main Content Area ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Action Card 1: Create a Trip
                          HomeActionCard.createTrip(
                            onTap: () async {
                              await context.push(RouteNames.createTrip);
                              if (context.mounted) {
                                context.read<HomeBloc>().add(
                                      const HomeFetchRequested(),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          // Action Card 2: Join a Trip
                          HomeActionCard.joinTrip(
                            onTap: () => _showJoinTripDialog(context),
                          ),
                          const SizedBox(height: 28),

                          // ── "Your Trips" Section Header ──────────────────
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              final count = state is HomeLoadedState
                                  ? state.filteredTrips.length
                                  : null;
                              final isFiltered = _activeStatusFilter != 'All' ||
                                  _searchController.text.isNotEmpty;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Your Trips',
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F2C3F),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      if (count != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2E8F0),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$count',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF334155),
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (_activeStatusFilter != 'All') ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _activeStatusFilter,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (isFiltered)
                                    GestureDetector(
                                      onTap: _onClearSearchAndFilters,
                                      child: Text(
                                        'Clear Filter',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0D9488),
                                        ),
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () => context.go(RouteNames.trips),
                                      child: Text(
                                        'View All',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0D9488),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          // ── Dynamic Trips List / Skeletons / Empty States ─
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              if (state is HomeLoadingState ||
                                  state is HomeInitialState) {
                                return const Column(
                                  children: [
                                    HomeTripCardSkeleton(),
                                    SizedBox(height: 14),
                                    HomeTripCardSkeleton(),
                                  ],
                                );
                              }

                              if (state is HomeErrorState) {
                                return _buildErrorState(
                                  message: state.message,
                                  onRetry: () {
                                    context.read<HomeBloc>().add(
                                          const HomeFetchRequested(),
                                        );
                                  },
                                );
                              }

                              if (state is HomeLoadedState) {
                                // 1. Global Empty State (User has 0 trips in total)
                                if (state.allTrips.isEmpty) {
                                  return _buildGlobalEmptyState(context);
                                }

                                // 2. Search/Filter Empty State (Trips exist, but none match criteria)
                                if (state.filteredTrips.isEmpty) {
                                  return _buildFilterEmptyState(
                                    query: state.searchQuery,
                                    statusFilter: state.activeStatusFilter,
                                  );
                                }

                                // 3. Populated Dynamic Trips List (Limit to 5 trips on Home)
                                final displayedTrips =
                                    state.filteredTrips.take(5).toList();

                                return Column(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: displayedTrips.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 14),
                                      itemBuilder: (context, index) {
                                        final trip = displayedTrips[index];
                                        return HomeTripCard.fromEntity(
                                          trip: trip,
                                          onTap: () {
                                            context.push(
                                              RouteNames.tripDetailsPath(trip.id),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    if (state.filteredTrips.length > 5) ...[
                                      const SizedBox(height: 14),
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: () =>
                                              context.go(RouteNames.trips),
                                          icon: const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                            color: AppColors.primaryDeepTeal,
                                          ),
                                          label: Text(
                                            'View all ${state.filteredTrips.length} trips',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryDeepTeal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Pinned Sticky Top Navigation Bar ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final offset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                return HomeStickyTopBar(
                  scrollOffset: offset,
                  onNotificationTap: () => _showNotificationSheet(context),
                  onProfileTap: () {
                    context.push(RouteNames.profile);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── High-Fidelity UI States ────────────────────────────────────────────────

  Widget _buildGlobalEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: Color(0xFF0F766E),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No trips planned yet',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your first trip or join friends to start coordinating itineraries and expenses together.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push(RouteNames.createTrip);
                if (context.mounted) {
                  context.read<HomeBloc>().add(const HomeFetchRequested());
                }
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Plan a Trip',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeepTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterEmptyState({
    required String query,
    required String statusFilter,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              size: 34,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No matching trips found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            query.isNotEmpty
                ? 'No trips matched "$query" under "$statusFilter".'
                : 'No trips with "$statusFilter" status currently exist.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: _onClearSearchAndFilters,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0D9488)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              'Reset Search & Filters',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.errorRed,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            'Unable to load trips',
            style: AppTypography.titleMedium(
              color: AppColors.errorRed,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(
              color: const Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modals & Actions ───────────────────────────────────────────────────────

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Trip notifications are up to date!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Collaborate on itinerary activities and split expenses with your group.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    String tempFilter = _activeStatusFilter;
    const filterOptions = [
      'All',
      'Upcoming',
      'Planning',
      'Ongoing',
      'Completed'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter by Status',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (tempFilter != 'All')
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempFilter = 'All';
                              });
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filterOptions.map((status) {
                        final isSelected = tempFilter == status;
                        return ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: const Color(0xFF004E64),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF004E64)
                                  : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() {
                                tempFilter = status;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _activeStatusFilter = tempFilter;
                          });
                          context.read<HomeBloc>().add(
                                HomeFilterStatusChanged(tempFilter),
                              );
                        },
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showJoinTripDialog(BuildContext parentContext) {
    showJoinTripDialog(parentContext);
  }
}

