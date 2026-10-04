import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../domain/entities/trip_review_draft.dart';
import '../widgets/budget_range_pill.dart';
import '../widgets/dotted_trail_decorator.dart';
import '../widgets/trip_category_icons.dart';
import '../widgets/trip_type_tile.dart';
import '../widgets/wave_header_clipper.dart';

/// Create Trip screen matching the design:
/// Destination selector, interactive date range cards, trip category tiles,
/// budget range selection, and sticky Continue button with map trail decoration.
class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final TextEditingController _destinationController =
      TextEditingController(text: 'Goa, India');

  DateTime _startDate = DateTime(2026, 10, 12);
  DateTime _endDate = DateTime(2026, 10, 15);

  String _selectedTripType = 'Vacation';
  String _selectedBudget = '₹20K – ₹50K';

  final List<String> _budgetOptions = const [
    '< ₹20K',
    '₹20K – ₹50K',
    '₹50K – ₹1L',
    '> ₹1L',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
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
      initialDate: _endDate.isAfter(_startDate) ? _endDate : _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
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

  void _onContinue() {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a destination to proceed.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final tripStyle = _selectedTripType == 'Vacation'
        ? 'Beach + Food'
        : _selectedTripType;

    final draft = TripReviewDraft(
      destination: destination,
      startDate: _startDate,
      endDate: _endDate,
      budget: _selectedBudget == '₹20K – ₹50K' ? '₹20k–₹30k' : _selectedBudget,
      tripStyle: tripStyle,
    );

    // Navigate to Invite Members screen passing the draft details
    context.push(RouteNames.inviteMembers, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
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
                    image: AssetImage('assets/images/create_trip_header.jpg'),
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
                      Column(
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
                          ),
                        ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // ── 1. Where to? Section ─────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.location_on,
                    title: 'Where to?',
                  ),
                  const SizedBox(height: 12),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        // Yellow Location Pin Badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_on,
                              color: Color(0xFFF59E0B),
                              size: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Destination Input Field
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter destination...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        // Clear Button (x)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _destinationController.clear();
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

                  const SizedBox(height: 24),

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
                    title: 'Trip type',
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

                  // ── 4. Budget Range Section ──────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Budget range',
                    subtitle: ' (per person)',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _budgetOptions.map((opt) {
                      return BudgetRangePill(
                        label: opt,
                        isSelected: _selectedBudget == opt,
                        onTap: () {
                          setState(() {
                            _selectedBudget = opt;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 36),

                  // ── 5. Continue Button ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 6. Decorative Dotted Trail ───────────────────────────
                  const DottedTrailDecorator(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
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
}
