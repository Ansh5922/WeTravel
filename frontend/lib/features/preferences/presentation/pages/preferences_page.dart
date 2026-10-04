import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../trips/presentation/widgets/invite_screen_decorations.dart';
import '../../domain/entities/user_travel_preferences.dart';
import '../widgets/preferences_category_card.dart';

/// "Set Your Preferences" screen matching the WeTravel design screenshot.
/// Allows travelers to configure their travel style, interests, dietary choices,
/// special requirements, and personalized notes for AI group itinerary alignment.
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // ── Selections State ───────────────────────────────────────────────────────
  String _selectedTravelStyle = 'Relaxed';
  final Set<String> _selectedInterests = {'Beaches'};
  String _selectedFoodPreference = 'Veg';
  final Set<String> _selectedSpecialRequirements = {'No alcohol'};
  final TextEditingController _notesController = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() {
      setState(() {
        _charCount = _notesController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _savePreferences() {
    final prefs = UserTravelPreferences(
      travelStyle: _selectedTravelStyle,
      interests: _selectedInterests.toList(),
      foodPreference: _selectedFoodPreference,
      specialRequirements: _selectedSpecialRequirements.toList(),
      additionalNotes: _notesController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Preferences saved! AI group match updated to 94%.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004E64),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Always navigate to Home screen after saving preferences
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Form Body ─────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 68,
              bottom: bottomPadding + 90,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Introduction Headline & Subtitle
                Text(
                  "Help us create a plan you'll love",
                  style: GoogleFonts.inter(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your preferences will be used to generate personalized itineraries and better group matches.",
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Travel Style (Single-Select)
                PreferencesCategoryCard(
                  iconWidget: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF004E64),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.beach_access_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  title: 'Travel Style',
                  options: const ['Relaxed', 'Balanced', 'Adventurous'],
                  selectedOptions: {_selectedTravelStyle},
                  onOptionToggled: (opt) {
                    setState(() {
                      _selectedTravelStyle = opt;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 3. Interests (Multi-Select)
                PreferencesCategoryCard(
                  iconWidget: const Icon(
                    Icons.backpack_rounded,
                    color: Color(0xFF004E64),
                    size: 26,
                  ),
                  title: 'Interests',
                  options: const [
                    'Beaches',
                    'Nature',
                    'Culture',
                    'Shopping',
                    'Adventure',
                    'Nightlife',
                  ],
                  selectedOptions: _selectedInterests,
                  isMultiSelect: true,
                  onOptionToggled: (opt) {
                    setState(() {
                      if (_selectedInterests.contains(opt)) {
                        if (_selectedInterests.length > 1) {
                          _selectedInterests.remove(opt);
                        }
                      } else {
                        _selectedInterests.add(opt);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 4. Food Preferences (Single-Select)
                PreferencesCategoryCard(
                  iconWidget: const Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xFF004E64),
                    size: 26,
                  ),
                  title: 'Food Preferences',
                  options: const ['Veg', 'Non Veg', 'Vegan', 'Jain'],
                  selectedOptions: {_selectedFoodPreference},
                  onOptionToggled: (opt) {
                    setState(() {
                      _selectedFoodPreference = opt;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 5. Special Requirements (Multi-Select)
                PreferencesCategoryCard(
                  iconWidget: const Icon(
                    Icons.accessible_rounded,
                    color: Color(0xFF004E64),
                    size: 26,
                  ),
                  title: 'Special Requirements',
                  options: const [
                    'No alcohol',
                    'No spicy food',
                    'Wheelchair access',
                    'Other',
                  ],
                  selectedOptions: _selectedSpecialRequirements,
                  isMultiSelect: true,
                  onOptionToggled: (opt) {
                    setState(() {
                      if (_selectedSpecialRequirements.contains(opt)) {
                        _selectedSpecialRequirements.remove(opt);
                      } else {
                        _selectedSpecialRequirements.add(opt);
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // 6. Additional Notes Box
                Text(
                  'Any additional notes? (optional)',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLength: 200,
                        maxLines: 3,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. We love sunsets, prefer local food, need a quiet stay, etc.',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                          counterText: '',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '$_charCount/200',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Fixed Top Header with Wave Background ────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, topPadding + 62),
                  painter: InviteHeaderPainter(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 8,
                    left: 10,
                    right: 14,
                    bottom: 8,
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
                          context.go(RouteNames.home);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Set Your Preferences',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          context.go(RouteNames.home);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom "Save Preferences" Button ───────────────────
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
                  onPressed: _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Save Preferences',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
