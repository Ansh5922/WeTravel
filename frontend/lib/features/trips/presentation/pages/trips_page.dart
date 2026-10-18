import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/we_travel_search_bar.dart';
import '../../../home/domain/entities/trip_summary_item.dart';
import '../../../home/presentation/widgets/avatar_stack.dart';

/// Dedicated "My Trips" screen inside the main authenticated shell.
/// Features trip category filters, search, trip cards with direct actions
/// (Workspace, Itinerary, Expenses), and seamless drawer & new trip triggers.
/// Renders a single unified bottom navigation bar via [AppShell].
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

  late List<TripSummaryItem> _allTrips;

  @override
  void initState() {
    super.initState();
    _allTrips = [
      ...TripSummaryItem.initialMockTrips(),
      const TripSummaryItem(
        id: 'himachal-trek',
        title: 'Himachal Backpacking',
        statusLabel: 'Completed',
        dateText: '15 – 22 Nov 2025',
        memberCount: 5,
        location: 'Manali, India',
        imagePath: 'assets/images/trip_goa.jpg',
        avatars: [
          'assets/images/avatar_user.jpg',
          'assets/images/avatar_1.jpg',
          'assets/images/avatar_2.jpg',
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TripSummaryItem> get _filteredTrips {
    final list = _allTrips.where((trip) {
      final matchesQuery = _searchQuery.isEmpty ||
          trip.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          trip.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _activeFilter == 'All' ||
          trip.statusLabel.toLowerCase() == _activeFilter.toLowerCase();

      return matchesQuery && matchesFilter;
    }).toList();

    if (_activeSort == 'alphabetical') {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else if (_activeSort == 'members') {
      list.sort((a, b) => b.memberCount.compareTo(a.memberCount));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final trips = _filteredTrips;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: statusBarHeight + 12,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Color(0xFF004E64),
                              size: 26,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Open navigation menu',
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'My Trips',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F2C3F),
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      // "+ Plan Trip" CTA
                      ElevatedButton.icon(
                        onPressed: () => context.push(RouteNames.createTrip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'New Trip',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Search & Filter Input Bar (Inbox Style) ───────────────
                  WeTravelSearchBar(
                    controller: _searchController,
                    hintText: 'Search destinations or trips...',
                    hasActiveFilter: _activeFilter != 'All' || _activeSort != 'default',
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
                  const SizedBox(height: 14),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Upcoming'),
                        _buildFilterChip('Planning'),
                        _buildFilterChip('Completed'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Trips List ─────────────────────────────────────────────
          if (trips.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.travel_explore_rounded,
                        size: 54,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No trips found',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create a new trip or modify your search filters.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => context.push(RouteNames.createTrip),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create a Trip'),
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
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final trip = trips[index];
                    return _TripCard(
                      trip: trip,
                      onTap: () {
                        context.push(RouteNames.tripDetailsPath(trip.id));
                      },
                      onWorkspaceTap: () {
                        context.push(RouteNames.tripDetailsPath(trip.id));
                      },
                      onItineraryTap: () {
                        context.push(RouteNames.itineraryPath(trip.id));
                      },
                      onExpensesTap: () {
                        context.push(RouteNames.expensesPath(trip.id));
                      },
                    );
                  },
                  childCount: trips.length,
                ),
              ),
            ),
        ],
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
                      children: ['All', 'Upcoming', 'Planning', 'Completed'].map((status) {
                        final isSelected = _activeFilter == status;
                        return ChoiceChip(
                          label: Text(status),
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
                              color: isSelected ? const Color(0xFF004E64) : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _activeFilter = status;
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
                        {'label': 'Default', 'value': 'default'},
                        {'label': 'Alphabetical (A–Z)', 'value': 'alphabetical'},
                        {'label': 'Most Members', 'value': 'members'},
                      ].map((sortItem) {
                        final isSelected = _activeSort == sortItem['value'];
                        return ChoiceChip(
                          label: Text(sortItem['label']!),
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
                              color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _activeSort = sortItem['value']!;
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF004E64) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripSummaryItem trip;
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

  @override
  Widget build(BuildContext context) {
    final isPlanning = trip.statusLabel.toLowerCase() == 'planning';
    final isCompleted = trip.statusLabel.toLowerCase() == 'completed';

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFB45309);

    if (isPlanning) {
      statusBg = const Color(0xFFE0F2FE);
      statusText = const Color(0xFF0284C7);
    } else if (isCompleted) {
      statusBg = const Color(0xFFF1F5F9);
      statusText = const Color(0xFF64748B);
    }

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
                  // Destination photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      trip.imagePath,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 84,
                        height: 84,
                        color: const Color(0xFFDEF2F1),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF004E64),
                          size: 28,
                        ),
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
                                trip.title,
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
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                trip.statusLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
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
                                trip.dateText,
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
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF0D9488),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trip.location,
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
                            AvatarStack(
                              avatarPaths: trip.avatars,
                              size: 22,
                              overlap: 7,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${trip.memberCount} buddies',
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
