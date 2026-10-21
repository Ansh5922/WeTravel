import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/we_travel_screen_header.dart';
import '../../../../core/widgets/we_travel_search_bar.dart';
import '../../domain/entities/trip_entity.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../widgets/join_trip_dialog.dart';

/// Dedicated "My Trips" screen connected to the backend via [TripBloc].
/// Features category filters, real-time search, sorting, pull-to-refresh,
/// rich trip cards with direct shortcuts (Workspace, Itinerary, Expenses),
/// and seamless drawer & new trip triggers.
class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All'; // 'All', 'Upcoming', 'Planning', 'Completed'
  String _activeSort = 'default'; // 'default', 'alphabetical', 'members'
  String _searchQuery = '';
  List<TripEntity> _cachedTrips = [];

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch to load trips from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TripBloc>().add(const TripsFetchRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TripEntity> _filterAndSortTrips(List<TripEntity> rawTrips) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = rawTrips.where((trip) {
      final matchesQuery = query.isEmpty ||
          trip.name.toLowerCase().contains(query) ||
          trip.members.any(
            (m) =>
                m.fullName.toLowerCase().contains(query) ||
                m.username.toLowerCase().contains(query),
          );

      final statusLower = trip.status.toLowerCase();
      final matchesFilter = switch (_activeFilter) {
        'All' => true,
        'Upcoming' => statusLower != 'completed',
        'Planning' => statusLower == 'planning',
        'Completed' => statusLower == 'completed',
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();

    if (_activeSort == 'alphabetical') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_activeSort == 'members') {
      filtered.sort((a, b) => b.members.length.compareTo(a.members.length));
    } else {
      // Default: chronological by start date or created date
      filtered.sort((a, b) {
        final dateA = a.tripStartDate ?? a.createdAt;
        final dateB = b.tripStartDate ?? b.createdAt;
        return dateB.compareTo(dateA);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is MyTripsLoadedState) {
            setState(() {
              _cachedTrips = state.trips;
            });
          } else if (state is TripCreatedState) {
            setState(() {
              if (!_cachedTrips.any((t) => t.id == state.trip.id)) {
                _cachedTrips.insert(0, state.trip);
              }
            });
          } else if (state is TripInviteSentState) {
            context.read<TripBloc>().add(const TripsFetchRequested());
          } else if (state is TripJoinedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Joined "${state.trip.name}" successfully!'),
                backgroundColor: const Color(0xFF005F73),
              ),
            );
            context.read<TripBloc>().add(const TripsFetchRequested());
            context.push(RouteNames.tripDetailsPath(state.trip.id));
          }
        },
        builder: (context, state) {
          if (state is MyTripsLoadedState) {
            _cachedTrips = state.trips;
          }

          final rawTrips = _cachedTrips;
          final displayedTrips = _filterAndSortTrips(rawTrips);
          final isLoading = state is TripLoadingState && rawTrips.isEmpty;

          return Column(
            children: [
              // ── 1. Reusable Top Header (Signature Dark Teal Curve) ───────
              const WeTravelScreenHeader(
                title: 'My Trips',
                showMenuButton: false,
              ),

              // ── 2. Fixed Search & Filter Section (Never Shifts on Refresh) ─
              Container(
                color: const Color(0xFFFAF9F6),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  children: [
                    WeTravelSearchBar(
                      controller: _searchController,
                      hintText: 'Search destinations or trips...',
                      hasActiveFilter:
                          _activeFilter != 'All' || _activeSort != 'default',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      onFilterTap: () => _showFilterSheet(context),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => showJoinTripDialog(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF005F73).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF005F73).withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.link_rounded, size: 16, color: Color(0xFF005F73)),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Join with Link',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF005F73),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildFilterChip('All', rawTrips.length),
                          _buildFilterChip(
                            'Upcoming',
                            rawTrips
                                .where((t) =>
                                    t.status.toLowerCase() != 'completed')
                                .length,
                          ),
                          _buildFilterChip(
                            'Planning',
                            rawTrips
                                .where((t) =>
                                    t.status.toLowerCase() == 'planning')
                                .length,
                          ),
                          _buildFilterChip(
                            'Completed',
                            rawTrips
                                .where((t) =>
                                    t.status.toLowerCase() == 'completed')
                                .length,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. Scrollable & Refreshable Content Area ─────────────────
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF004E64),
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    context.read<TripBloc>().add(const TripsFetchRequested());
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // ── Trips Body State Handling ────────────────────────
                      if (isLoading)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildSkeletonCard(),
                              childCount: 3,
                            ),
                          ),
                        )
                      else if (state is TripErrorState && rawTrips.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildErrorState(state.message),
                        )
                      else if (displayedTrips.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(rawTrips.isEmpty),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final trip = displayedTrips[index];
                                return _TripCard(
                                  trip: trip,
                                  onTap: () {
                                    context.push(
                                        RouteNames.tripDetailsPath(trip.id));
                                  },
                                  onWorkspaceTap: () {
                                    context.push(
                                        RouteNames.tripDetailsPath(trip.id));
                                  },
                                  onItineraryTap: () {
                                    context.push(
                                        RouteNames.itineraryPath(trip.id));
                                  },
                                  onExpensesTap: () {
                                    context.push(
                                        RouteNames.expensesPath(trip.id));
                                  },
                                );
                              },
                              childCount: displayedTrips.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 130,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load trips',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TripBloc>().add(const TripsFetchRequested());
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004E64),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF004E64).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                size: 40,
                color: Color(0xFF004E64),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCompletelyEmpty ? 'No trips yet' : 'No matching trips found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isCompletelyEmpty
                  ? 'Create your first collaborative trip or accept an invite to plan with friends.'
                  : 'Try modifying your search query or reset your filters.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isCompletelyEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push(RouteNames.createTrip),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Plan a Trip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => showJoinTripDialog(context),
                    icon: const Icon(Icons.link_rounded, size: 18),
                    label: const Text('Join with Link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF005F73),
                      side: const BorderSide(color: Color(0xFF005F73), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _activeFilter = 'All';
                    _activeSort = 'default';
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF004E64),
                  side: const BorderSide(color: Color(0xFF004E64)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter & Sort Trips',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (_activeFilter != 'All' || _activeSort != 'default')
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _activeFilter = 'All';
                                _activeSort = 'default';
                              });
                              setState(() {});
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
                    Text(
                      'STATUS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ['All', 'Upcoming', 'Planning', 'Completed'].map((filter) {
                        final isSelected = _activeFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: const Color(0xFF004E64),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
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
                            setModalState(() {
                              _activeFilter = filter;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'SORT BY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        {'label': 'Latest', 'value': 'default'},
                        {'label': 'Alphabetical (A–Z)', 'value': 'alphabetical'},
                        {'label': 'Most Buddies', 'value': 'members'},
                      ].map((item) {
                        final isSelected = _activeSort == item['value'];
                        return ChoiceChip(
                          label: Text(item['label']!),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFF59E0B)
                                  : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _activeSort = item['value']!;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeFilter = label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF004E64) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              if (count >= 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback onTap;
  final VoidCallback onWorkspaceTap;
  final VoidCallback onItineraryTap;
  final VoidCallback onExpensesTap;

  const _TripCard({
    required this.trip,
    required this.onTap,
    required this.onWorkspaceTap,
    required this.onItineraryTap,
    required this.onExpensesTap,
  });

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String get _dateRangeText {
    if (trip.tripStartDate != null && trip.tripEndDate != null) {
      return '${_formatDate(trip.tripStartDate!)} – ${_formatDate(trip.tripEndDate!)}';
    } else if (trip.tripStartDate != null) {
      return 'Starting ${_formatDate(trip.tripStartDate!)}';
    }
    return 'Dates flexible';
  }

  String get _sampleFallbackImage {
    const sampleImages = [
      'assets/images/trip_goa.jpg',
      'assets/images/trip_kerala.jpg',
      'assets/images/trip_manali.jpg',
      'assets/images/hero_coast.jpg',
    ];
    final index = trip.name.hashCode.abs() % sampleImages.length;
    return sampleImages[index];
  }

  @override
  Widget build(BuildContext context) {
    final statusLower = trip.status.toLowerCase();
    final isPlanning = statusLower == 'planning';
    final isCompleted = statusLower == 'completed';

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFB45309);
    String statusLabel = 'Ongoing';

    if (isPlanning) {
      statusBg = const Color(0xFFE0F2FE);
      statusText = const Color(0xFF0284C7);
      statusLabel = 'Planning';
    } else if (isCompleted) {
      statusBg = const Color(0xFFF1F5F9);
      statusText = const Color(0xFF64748B);
      statusLabel = 'Completed';
    }

    final hasNetworkCover =
        trip.coverImageUrl != null && trip.coverImageUrl!.trim().startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Info Clickable Area
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination photo (Network with fallback to asset)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 86,
                      height: 86,
                      child: hasNetworkCover
                          ? Image.network(
                              trip.coverImageUrl!.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                _sampleFallbackImage,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              _sampleFallbackImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Trip Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                trip.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _dateRangeText,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Avatar stack & count
                        Row(
                          children: [
                            _buildMemberAvatarStack(trip.members),
                            const SizedBox(width: 8),
                            Text(
                              '${trip.members.length} ${trip.members.length == 1 ? 'buddy' : 'buddies'}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
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

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // ── Quick Action Shortcut Chips ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildActionChip(
                  icon: Icons.space_dashboard_rounded,
                  label: 'Workspace',
                  onTap: onWorkspaceTap,
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.calendar_month_outlined,
                  label: 'Itinerary',
                  onTap: onItineraryTap,
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.receipt_long_outlined,
                  label: 'Expenses',
                  onTap: onExpensesTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatarStack(List<TripGroupMemberEntity> members) {
    if (members.isEmpty) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFF004E64),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.person, size: 13, color: Colors.white),
        ),
      );
    }

    final displayMembers = members.take(3).toList();
    const avatarColors = [
      Color(0xFF004E64),
      Color(0xFF0D9488),
      Color(0xFFF59E0B),
      Color(0xFF6366F1),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < displayMembers.length; i++)
          Align(
            widthFactor: 0.72,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: avatarColors[i % avatarColors.length],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  displayMembers[i].fullName.isNotEmpty
                      ? displayMembers[i].fullName[0].toUpperCase()
                      : (displayMembers[i].username.isNotEmpty
                          ? displayMembers[i].username[0].toUpperCase()
                          : '?'),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF004E64)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004E64),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
