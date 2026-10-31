import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/we_travel_drawer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../domain/entities/itinerary_entity.dart';
import '../bloc/itinerary_bloc.dart';
import '../bloc/itinerary_event.dart';
import '../bloc/itinerary_state.dart';
import '../widgets/itinerary_screen_widgets.dart';

/// Dynamic Itinerary Screen for WeTravel.
/// Can be displayed standalone or embedded within the unified TripDetailsPage.
///
/// Features:
/// - AI Plan Variant Selector (Optimal / Balanced / Budget)
/// - "Regenerate with AI" modal with custom pace/focus constraints
/// - Transit & Travel Booking Hub (Flights, Trains, Buses, Cabs)
/// - Day filter selector (Day 1, Day 2, Day 3, ...)
/// - Day-by-Day Chronological Event Timeline with real activity costs, transit icons, and locations
class ItineraryPage extends StatefulWidget {
  final String tripId;
  final bool isEmbedded;

  const ItineraryPage({
    super.key,
    required this.tripId,
    this.isEmbedded = false,
  });

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  int _selectedDay = 1;

  @override
  void initState() {
    super.initState();
    final isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv && widget.tripId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ItineraryBloc>().add(ItinerariesFetchRequested(widget.tripId));
        }
      });
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.trips);
    }
  }

  Future<void> _openBookingUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching link: $e')),
        );
      }
    }
  }

  void _showBookingProvidersModal(BuildContext context, String category, String destination) {
    final Map<String, List<Map<String, String>>> providersByCategory = {
      'Hotels & Stays': [
        {
          'name': 'MakeMyTrip',
          'desc': 'Book hotels, resorts & homestays in $destination',
          'url': 'https://www.makemytrip.com/hotels/hotel-listing/?city=${Uri.encodeComponent(destination)}',
          'badge': 'Popular in India',
        },
        {
          'name': 'Booking.com',
          'desc': 'Instant confirmation on verified hotels & apartments',
          'url': 'https://www.booking.com/searchresults.html?ss=${Uri.encodeComponent(destination)}',
          'badge': 'Global Selection',
        },
        {
          'name': 'Goibibo',
          'desc': 'Special app discounts and goCash rewards',
          'url': 'https://www.goibibo.com/hotels/',
          'badge': 'Budget Deals',
        },
        {
          'name': 'Airbnb',
          'desc': 'Unique villas, beachfront stays & private rooms',
          'url': 'https://www.airbnb.com/s/${Uri.encodeComponent(destination)}/homes',
          'badge': 'Private Stays',
        },
      ],
      'Flights': [
        {
          'name': 'Google Flights',
          'desc': 'Real-time fare tracking & fastest flight routes',
          'url': 'https://www.google.com/travel/flights?q=flights+to+${Uri.encodeComponent(destination)}',
          'badge': 'Best Comparison',
        },
        {
          'name': 'Skyscanner',
          'desc': 'Search 1000+ airlines with flexible date prices',
          'url': 'https://www.skyscanner.net',
          'badge': 'Price Alerts',
        },
        {
          'name': 'MakeMyTrip Flights',
          'desc': 'Domestic & international flight cashback offers',
          'url': 'https://www.makemytrip.com/flights/',
          'badge': 'Special Offers',
        },
      ],
      'Trains': [
        {
          'name': 'IRCTC Next Generation',
          'desc': 'Official Indian Railways seat reservation portal',
          'url': 'https://www.irctc.co.in/nget/train-search',
          'badge': 'Official Govt',
        },
        {
          'name': 'ConfirmTkt',
          'desc': 'Waitlist prediction, alternate routes & tatkal status',
          'url': 'https://www.confirmtkt.com',
          'badge': 'WL Predictor',
        },
      ],
      'Buses': [
        {
          'name': 'RedBus',
          'desc': 'Over 3,500 bus operators across India',
          'url': 'https://www.redbus.in/bus-tickets/${Uri.encodeComponent(destination)}',
          'badge': 'Top Rated',
        },
        {
          'name': 'AbhiBus',
          'desc': 'State road transport (RTC) & AC sleeper buses',
          'url': 'https://www.abhibus.com',
          'badge': 'Govt RTCs',
        },
      ],
      'Cabs & Rental': [
        {
          'name': 'Uber',
          'desc': 'Book local city cabs, hourly rentals & outstation',
          'url': 'https://m.uber.com',
          'badge': 'Instant Ride',
        },
        {
          'name': 'Ola Cabs',
          'desc': 'Daily city commute, Prime sedans & SUV rentals',
          'url': 'https://www.olacabs.com',
          'badge': 'Wide Reach',
        },
      ],
    };

    final providers = providersByCategory[category] ?? providersByCategory['Hotels & Stays']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDEF2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.travel_explore_rounded,
                        color: Color(0xFF004E64),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$category in $destination',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                          Text(
                            'Choose an aggregator to view fares & book directly',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...providers.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _openBookingUrl(p['url']!);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF004E64).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                color: Color(0xFF004E64),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        p['name']!,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDEF2F1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          p['badge']!,
                                          style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF004E64),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    p['desc']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
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
        );
      },
    );
  }



  void _showRegenerateDialog(BuildContext context, TripEntity? trip) {
    final cleanDest = trip?.name.isNotEmpty == true
        ? trip!.name.replaceAll(RegExp(r'\b(trip|getaway|vacation|tour|escapade|beach)\b', caseSensitive: false), '').trim()
        : '';
    final defaultDestination = cleanDest.isNotEmpty ? cleanDest : (trip?.name ?? 'Destination');
    final originController = TextEditingController(text: 'Delhi');
    final destinationController = TextEditingController(text: defaultDestination);
    String selectedFocus = 'Balanced';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF004E64), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Generate AI Itinerary',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Re-synthesizes all day plans using updated group consensus and your focus preference.',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: originController,
                          decoration: InputDecoration(
                            labelText: 'Departure City',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: destinationController,
                          decoration: InputDecoration(
                            labelText: 'Destination',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Focus Preference',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Balanced', 'Adventure & Outdoors', 'Food & Cafes', 'Relaxed & Scenic', 'Budget Saver']
                        .map((f) {
                      final isSel = selectedFocus == f;
                      return ChoiceChip(
                        label: Text(f, style: GoogleFonts.inter(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                        selected: isSel,
                        selectedColor: const Color(0xFF004E64),
                        labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF004E64)),
                        onSelected: (val) {
                          setModalState(() => selectedFocus = f);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final origin = originController.text.trim();
                        final destination = destinationController.text.trim();
                        if (origin.isEmpty || destination.isEmpty) return;

                        Navigator.pop(modalCtx);

                        final sDate = trip?.tripStartDate != null
                            ? '${trip!.tripStartDate!.year}-${trip.tripStartDate!.month.toString().padLeft(2, '0')}-${trip.tripStartDate!.day.toString().padLeft(2, '0')}'
                            : DateTime.now().toIso8601String().split('T').first;

                        final eDate = trip?.tripEndDate != null
                            ? '${trip!.tripEndDate!.year}-${trip.tripEndDate!.month.toString().padLeft(2, '0')}-${trip.tripEndDate!.day.toString().padLeft(2, '0')}'
                            : DateTime.now().add(const Duration(days: 4)).toIso8601String().split('T').first;

                        context.read<ItineraryBloc>().add(
                              ItineraryGenerateRequested(
                                tripId: widget.tripId,
                                origin: origin,
                                destination: destination,
                                startDate: sDate,
                                endDate: eDate,
                                memberCount: trip?.members.isNotEmpty == true ? trip!.members.length : 2,
                                constraints: {'focus': selectedFocus},
                              ),
                            );
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'Generate New Itineraries',
                        style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004E64),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final tripState = context.watch<TripBloc>().state;
    TripEntity? trip;
    if (tripState is TripDetailLoadedState && tripState.trip.id == widget.tripId) {
      trip = tripState.trip;
    }

    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState ? authState.user.id : '';
    final currentMember = trip?.members.where((m) => m.userId == currentUserId).firstOrNull;
    final bool isCurrentUserAdmin = trip != null && (trip.createdBy == currentUserId || currentMember?.role == 'admin');

    final destination = trip?.name.split(' ').first ?? 'Destination';

    final content = BlocBuilder<ItineraryBloc, ItineraryState>(
      builder: (context, itinState) {
        if (itinState is ItineraryLoadingState) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: Color(0xFF004E64)),
            ),
          );
        }

        List<ItineraryEntity> allItineraries = [];
        ItineraryEntity? activeItinerary;

        if (itinState is ItinerariesLoadedState) {
          allItineraries = itinState.itineraries;
          activeItinerary = itinState.selectedItinerary ?? allItineraries.firstOrNull;
        } else if (itinState is ItineraryDetailLoadedState) {
          activeItinerary = itinState.itinerary;
        }

        // Group items by day
        final Map<int, List<ItineraryItemEntity>> dayGroups = {};
        if (activeItinerary != null) {
          for (final item in activeItinerary.items) {
            dayGroups.putIfAbsent(item.dayNumber, () => []).add(item);
          }
        }

        final availableDays = dayGroups.keys.toList()..sort();
        if (availableDays.isNotEmpty && !availableDays.contains(_selectedDay)) {
          _selectedDay = availableDays.first;
        }

        final currentDayItems = dayGroups[_selectedDay] ?? [];

        final consensus = tripState is TripDetailLoadedState ? tripState.consensus : null;
        final pace = consensus?.majorityPace ?? 'Moderate';
        final focus = consensus?.dominantTravelStyle ?? 'Beaches & Culture';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Banner: AI Plan Selected with Warm Amber Button ──
              ItineraryAiPlanBanner(
                hasItinerary: activeItinerary != null,
                planTitle: activeItinerary?.variantType ?? (allItineraries.isNotEmpty ? 'Optimal' : null),
                planSummary: activeItinerary?.summary,
                canRegenerate: isCurrentUserAdmin,
                onRegenerate: () {
                  if (isCurrentUserAdmin) {
                    _showRegenerateDialog(context, trip);
                  }
                },
              ),
              const SizedBox(height: 14),

              // ── 2. Pace & Focus Dropdown Filter Cards ────────────────────
              ItineraryPaceFocusFilters(
                pace: pace,
                focus: focus,
                onTapPace: () => _showPaceSelector(context, trip),
                onTapFocus: () => _showFocusSelector(context, trip),
              ),
              const SizedBox(height: 18),

              // ── 3. Travel Plans Section (Optimal, Budget, Relaxed) ───────
              if (allItineraries.isNotEmpty) ...[
                ItineraryPlanCardsRow(
                  itineraries: allItineraries,
                  selectedItineraryId: activeItinerary?.id,
                  onSelectPlan: (planId) {
                    if (isCurrentUserAdmin) {
                      context.read<ItineraryBloc>().add(
                            ItinerarySelectRequested(
                              tripId: widget.tripId,
                              itineraryId: planId,
                            ),
                          );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Only the trip admin can select the active group itinerary.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 18),
              ],

              // ── 4. Day Selector (Day 1 Fri 24, Day 2 Sat 25...) ─────────
              if (availableDays.isNotEmpty) ...[
                ItineraryDaySelector(
                  days: availableDays,
                  selectedDay: _selectedDay,
                  tripStartDate: trip?.tripStartDate,
                  onDaySelected: (dayNum) {
                    setState(() => _selectedDay = dayNum);
                  },
                ),
                const SizedBox(height: 18),
              ],

              // ── 5. Chronological Day Timeline Items ──────────────────────
              if (currentDayItems.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentDayItems.length,
                  itemBuilder: (context, index) {
                    return ItineraryTimelineItem(
                      item: currentDayItems[index],
                      isLast: index == currentDayItems.length - 1,
                    );
                  },
                ),
              ] else ...[
                _buildEmptyDayState(context, trip, activeItinerary == null, isCurrentUserAdmin),
              ],
              const SizedBox(height: 16),

              // ── 6. Booking Hub Card (Hotels, Flights, Trains, Buses, Cabs) ───────
              ItineraryBookingHub(
                onHotels: () => _showBookingProvidersModal(context, 'Hotels & Stays', destination),
                onFlights: () => _showBookingProvidersModal(context, 'Flights', destination),
                onTrains: () => _showBookingProvidersModal(context, 'Trains', destination),
                onBuses: () => _showBookingProvidersModal(context, 'Buses', destination),
                onCabs: () => _showBookingProvidersModal(context, 'Cabs & Rental', destination),
              ),
              const SizedBox(height: 16),

              // ── 7. Scenic Botanical Leaves & Dotted Trail Footer ─────────
              const ItineraryScenicFooter(),
            ],
          ),
        );
      },
    );

    if (widget.isEmbedded) {
      return content;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        drawer: const WeTravelDrawer(),
        body: content,
      ),
    );
  }

  void _showPaceSelector(BuildContext context, TripEntity? trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final paces = ['Relaxed', 'Moderate', 'Fast-paced'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Trip Pace',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose the activity intensity for your group schedule.',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ...paces.map((p) => ListTile(
                      title: Text(p, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      leading: const Icon(Icons.speed_rounded, color: AppColors.primaryDeepTeal),
                      onTap: () {
                        Navigator.pop(ctx);
                        final auth = context.read<AuthBloc>().state;
                        final uid = auth is AuthAuthenticatedState ? auth.user.id : '';
                        final isAdm = trip != null && (trip.createdBy == uid || trip.members.any((m) => m.userId == uid && m.role == 'admin'));
                        if (isAdm) {
                          _showRegenerateDialog(context, trip);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Only the trip admin can customize trip pace and regenerate.')),
                          );
                        }
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFocusSelector(BuildContext context, TripEntity? trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final focuses = [
          'Beaches & Culture',
          'Adventure & Outdoors',
          'Food & Cafes',
          'Relaxed & Scenic',
          'Heritage & History',
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Trip Focus',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose the main theme and highlights for your itinerary.',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ...focuses.map((f) => ListTile(
                      title: Text(f, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      leading: const Icon(Icons.track_changes_rounded, color: AppColors.primaryDeepTeal),
                      onTap: () {
                        Navigator.pop(ctx);
                        final auth = context.read<AuthBloc>().state;
                        final uid = auth is AuthAuthenticatedState ? auth.user.id : '';
                        final isAdm = trip != null && (trip.createdBy == uid || trip.members.any((m) => m.userId == uid && m.role == 'admin'));
                        if (isAdm) {
                          _showRegenerateDialog(context, trip);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Only the trip admin can customize trip pace and regenerate.')),
                          );
                        }
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDayState(
    BuildContext context,
    TripEntity? trip,
    bool hasNoItinerary,
    bool isCurrentUserAdmin,
  ) {
    final title = hasNoItinerary
        ? (isCurrentUserAdmin ? 'No Itinerary Generated Yet' : 'No Itinerary Ready')
        : 'No Activities for Day $_selectedDay';

    final subtitle = hasNoItinerary
        ? (isCurrentUserAdmin
            ? 'Tap "Generate Itineraries" to synthesize tailored day plans from group preferences.'
            : 'The itinerary has not been generated by the trip admin yet.')
        : (isCurrentUserAdmin
            ? 'Tap to customize or add activities for this day.'
            : 'No scheduled activities for this day.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAE2D8)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F6F4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 32,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          if (hasNoItinerary && isCurrentUserAdmin) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _showRegenerateDialog(context, trip),
              icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              label: Text(
                'Generate Itineraries',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeepTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
