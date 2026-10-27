import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/destination_photo_service.dart';
import '../../domain/entities/trip_review_draft.dart';
import '../widgets/budget_range_pill.dart';
import '../widgets/trip_category_icons.dart';
import '../widgets/trip_type_tile.dart';
import '../widgets/wave_header_clipper.dart';

/// Create Trip screen matching the design:
/// Destination picker, interactive dynamic date range cards,
/// trip category tiles, interactive budget slider with tier pills,
/// and sticky Continue button at the bottom.
class CreateTripPage extends StatefulWidget {
  final TripReviewDraft? initialDraft;

  const CreateTripPage({super.key, this.initialDraft});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();

  Timer? _placesDebounceTimer;
  List<Map<String, dynamic>> _livePlaces = [];
  bool _isSearchingPlaces = false;

  late DateTime _startDate;
  late DateTime _endDate;

  String _selectedTripType = 'Vacation';
  double _budgetSliderValue = 35000;
  String _selectedBudgetTier = '₹20K – ₹50K';

  final List<String> _budgetOptions = const [
    '< ₹20K',
    '₹20K – ₹50K',
    '₹50K – ₹1L',
    '> ₹1L',
  ];

  @override
  void initState() {
    super.initState();
    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        final text = _destinationController.text.trim();
        if (text.isNotEmpty && !_isValidDestination(text)) {
          _showInvalidDestinationSnackbar();
        }
      }
    });

    if (widget.initialDraft != null) {
      final draft = widget.initialDraft!;
      _destinationController.text = draft.destination;
      _startDate = draft.startDate;
      _endDate = draft.endDate;
      _selectedTripType = draft.tripStyle;
      _selectedBudgetTier = draft.budget;
      _budgetSliderValue = 35000;
    } else {
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
      _endDate = _startDate.add(const Duration(days: 3));
    }
  }

  @override
  void dispose() {
    _placesDebounceTimer?.cancel();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _onDestinationChanged(String query) {
    setState(() {});
    _placesDebounceTimer?.cancel();
    final clean = query.trim();
    if (clean.length < 2) {
      if (_livePlaces.isNotEmpty || _isSearchingPlaces) {
        setState(() {
          _livePlaces = [];
          _isSearchingPlaces = false;
        });
      }
      return;
    }

    setState(() {
      _isSearchingPlaces = true;
    });

    _placesDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await ServiceLocator.tripRepository.searchPlaces(clean);
        if (mounted && _destinationController.text.trim() == clean) {
          setState(() {
            _livePlaces = results;
            _isSearchingPlaces = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isSearchingPlaces = false;
          });
        }
      }
    });
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(today) ? today : _startDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005F73),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 3));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005F73),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _onBudgetSliderChanged(double value) {
    setState(() {
      _budgetSliderValue = value;
      if (value < 20000) {
        _selectedBudgetTier = '< ₹20K';
      } else if (value <= 50000) {
        _selectedBudgetTier = '₹20K – ₹50K';
      } else if (value <= 100000) {
        _selectedBudgetTier = '₹50K – ₹1L';
      } else {
        _selectedBudgetTier = '> ₹1L';
      }
    });
  }

  void _onBudgetTierTapped(String tier) {
    setState(() {
      _selectedBudgetTier = tier;
      switch (tier) {
        case '< ₹20K':
          _budgetSliderValue = 15000;
          break;
        case '₹20K – ₹50K':
          _budgetSliderValue = 35000;
          break;
        case '₹50K – ₹1L':
          _budgetSliderValue = 75000;
          break;
        case '> ₹1L':
          _budgetSliderValue = 125000;
          break;
      }
    });
  }

  String _formatCurrency(double val) {
    if (val >= 100000) {
      final inLakhs = val / 100000;
      return '₹${inLakhs.toStringAsFixed(1)}L';
    }
    final inThousands = (val / 1000).round();
    return '₹$inThousands' 'K';
  }

  String _resolveCoverImageUrl(String destination, String style) {
    return DestinationPhotoService.resolveCoverImageUrl(destination, style);
  }

  bool _isValidDestination(String input) {
    final trimmed = input.trim();
    if (trimmed.length < 2 || trimmed.length > 60) return false;
    // Must contain at least two alphabetic characters
    if (!RegExp(r'[a-zA-Z].*[a-zA-Z]').hasMatch(trimmed)) return false;
    // Allowed characters: letters, numbers (for places like Sector 17), spaces, commas, hyphens, dots, apostrophes
    if (!RegExp(r"^[a-zA-Z0-9\s,'\.-]+$").hasMatch(trimmed)) return false;
    // Reject repeating single character sequences like "aaaaaa" or "....."
    if (RegExp(r'^(.)\1+$').hasMatch(trimmed)) return false;
    return true;
  }

  void _showInvalidDestinationSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please enter a valid destination.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFBA1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();

    final destination = _destinationController.text.trim();
    if (!_isValidDestination(destination)) {
      _showInvalidDestinationSnackbar();
      return;
    }

    final tripStyle = _selectedTripType == 'Vacation'
        ? 'Beach + Food'
        : _selectedTripType;

    final draft = TripReviewDraft(
      destination: destination,
      startDate: _startDate,
      endDate: _endDate,
      budget: '₹${(_budgetSliderValue / 1000).round()}k ($_selectedBudgetTier)',
      tripStyle: tripStyle,
      coverImageUrl: _resolveCoverImageUrl(destination, tripStyle),
    );

    context.push(RouteNames.reviewTrip, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next: Review Trip',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                    color: Color(0xFF0F172A),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RepaintBoundary(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── Top Scenic Header with Curved Edge ─────────────────────────
            ClipPath(
              clipper: WaveHeaderClipper(),
              child: Container(
                height: 205 + statusBarHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/hero_coast.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 10,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 14),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Create Trip',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Let's plan your next adventure",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.90),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form Content ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── 1. Where to? Section ─────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.location_on,
                    title: 'Where to?',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        // Yellow Location Pin Badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_on,
                              color: Color(0xFFF59E0B),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Destination Input Field
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            focusNode: _destinationFocusNode,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _onContinue(),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Enter destination (e.g. Goa, Manali, Bali)...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13.5,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: _onDestinationChanged,
                          ),
                        ),

                        // Clear Button (x)
                        if (_destinationController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _destinationController.clear();
                                _livePlaces = [];
                                _isSearchingPlaces = false;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Destination Autofill Suggestions ──────────────────────
                  const SizedBox(height: 8),
                  _buildDestinationSuggestions(),

                  const SizedBox(height: 20),

                  // ── 2. When? Section ─────────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.calendar_today_rounded,
                    title: 'When?',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Start Date Card
                      Expanded(
                        child: _buildDateCard(
                          label: 'Start date',
                          dateString: _formatDate(_startDate),
                          onTap: _pickStartDate,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // End Date Card
                      Expanded(
                        child: _buildDateCard(
                          label: 'End date',
                          dateString: _formatDate(_endDate),
                          onTap: _pickEndDate,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── 3. Trip Type Section ─────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.tour_rounded,
                    title: 'Trip style',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TripTypeTile(
                        label: 'Vacation',
                        iconBuilder: (color) => PalmTreeIcon(color: color, size: 28),
                        isSelected: _selectedTripType == 'Vacation',
                        onTap: () {
                          setState(() {
                            _selectedTripType = 'Vacation';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      TripTypeTile(
                        label: 'Adventure',
                        iconBuilder: (color) => AdventureMountainIcon(color: color, size: 27),
                        isSelected: _selectedTripType == 'Adventure',
                        onTap: () {
                          setState(() {
                            _selectedTripType = 'Adventure';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      TripTypeTile(
                        label: 'Food',
                        iconBuilder: (color) => DiningForkKnifeIcon(color: color, size: 26),
                        isSelected: _selectedTripType == 'Food',
                        onTap: () {
                          setState(() {
                            _selectedTripType = 'Food';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      TripTypeTile(
                        label: 'Cultural',
                        iconBuilder: (color) => TempleIcon(color: color, size: 26),
                        isSelected: _selectedTripType == 'Cultural',
                        onTap: () {
                          setState(() {
                            _selectedTripType = 'Cultural';
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── 4. Budget Slider & Tiers Section ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader(
                        icon: Icons.currency_rupee_rounded,
                        title: 'Budget',
                        subtitle: ' (per person)',
                      ),
                      Text(
                        _formatCurrency(_budgetSliderValue),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF005F73),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Interactive Budget Slider Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFF59E0B),
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                              thumbColor: const Color(0xFF005F73),
                              overlayColor: const Color(0xFF005F73).withValues(alpha: 0.12),
                              trackHeight: 5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            ),
                            child: Slider(
                              value: _budgetSliderValue,
                              min: 5000,
                              max: 150000,
                              divisions: 29,
                              onChanged: _onBudgetSliderChanged,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹5K (Budget)',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                              Text(
                                '₹1.5L+ (Luxury)',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Budget Tier Quick Pills
                  Semantics(
                    container: true,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _budgetOptions.map((opt) {
                        return BudgetRangePill(
                          label: opt,
                          isSelected: _selectedBudgetTier == opt,
                          onTap: () => _onBudgetTierTapped(opt),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ── Helper Widgets ────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFF005F73),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF005F73),
            letterSpacing: -0.2,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
      ],
    );
  }

  Widget _buildDateCard({
    required String label,
    required String dateString,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: Color(0xFF005F73),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dateString,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _popularDestinations = [
    'Goa',
    'Manali',
    'Ladakh',
    'Jaipur',
    'Udaipur',
    'Rishikesh',
    'Kerala',
    'Varanasi',
    'Ooty',
    'Shimla',
    'Coorg',
    'Kasol',
    'Andaman',
    'Darjeeling',
    'Agra',
    'Amritsar',
    'Hampi',
    'Munnar',
  ];

  Widget _buildDestinationSuggestions() {
    if (_isSearchingPlaces) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005F73)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Searching destinations worldwide...',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (_livePlaces.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _livePlaces.take(5).map((place) {
              final name = place['name']?.toString() ?? '';
              final country = place['country']?.toString() ?? '';
              final state = place['state']?.toString() ?? '';
              final displayName = place['displayName']?.toString() ?? name;
              final subtitle = [state, country].where((s) => s.isNotEmpty).join(', ');

              return InkWell(
                onTap: () {
                  setState(() {
                    _destinationController.text = displayName.isNotEmpty ? displayName : name;
                    _livePlaces = [];
                  });
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.north_west_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    final query = _destinationController.text.trim().toLowerCase();
    final matches = _popularDestinations.where((d) {
      if (query.isEmpty) return true;
      return d.toLowerCase().contains(query);
    }).toList();

    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: matches.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final dest = matches[i];
          final isSelected = _destinationController.text.trim().toLowerCase() == dest.toLowerCase();
          return InkWell(
            onTap: () {
              setState(() {
                _destinationController.text = dest;
                _livePlaces = [];
              });
              FocusScope.of(context).unfocus();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF005F73) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF005F73) : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 13,
                    color: isSelected ? Colors.white : const Color(0xFF005F73),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dest,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
