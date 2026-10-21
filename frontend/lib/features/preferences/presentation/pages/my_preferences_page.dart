import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/we_travel_screen_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';

/// Production-ready "My Preferences" screen.
/// - Currency in Indian Rupees (₹) across all budget fields.
/// - Minimum selectable price is ₹500/day. Custom prices can be entered freely.
/// - Selected chips and cards feel like tactile buttons with rich amber depth and WHITE text.
/// - Zero emojis in text labels.
/// - Sticky bottom CTA button with zero content overlap.
/// - Instant 0ms optimistic state management via ProfileBloc.
class MyPreferencesPage extends StatefulWidget {
  const MyPreferencesPage({super.key});

  @override
  State<MyPreferencesPage> createState() => _MyPreferencesPageState();
}

class _MyPreferencesPageState extends State<MyPreferencesPage> {
  // ── 1. Travel Style / Vibe ────────────────────────────────────────────────
  static const List<String> _travelStyles = [
    'Adventure',
    'Relaxed',
    'Cultural & Local',
    'Luxury',
    'Backpacker',
    'Road Trip',
  ];
  late String _selectedTravelStyle;

  // ── 2. Trip Pacing ────────────────────────────────────────────────────────
  static const Map<String, String> _pacingOptions = {
    'slow': 'Chill & Leisurely (1-2 stops/day)',
    'moderate': 'Balanced (standard exploration)',
    'fast': 'Action-Packed (sunrise to late night)',
  };
  late String _selectedPace; // 'slow', 'moderate', or 'fast'

  // ── 3. Daily Budget in Indian Rupees (₹) ──────────────────────────────────
  static const List<Map<String, dynamic>> _budgetTiers = [
    {'tier': 'backpacker', 'label': 'Backpacker (< ₹1,500)', 'defaultVal': 1200.0},
    {'tier': 'moderate', 'label': 'Moderate (₹1,500 – ₹5,000)', 'defaultVal': 3000.0},
    {'tier': 'luxury', 'label': 'Luxury (₹5,000+)', 'defaultVal': 8000.0},
  ];
  late String _selectedBudgetTier;
  late double _dailyBudget; // Stored in INR (minimum ₹500)

  // ── 4. Dietary Requirements ───────────────────────────────────────────────
  static const List<String> _dietaryOptions = [
    'No restrictions',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-Free',
  ];
  late String _selectedDiet;

  // ── 5. Health & Climate Needs (USP) ───────────────────────────────────────
  static const Map<String, String> _climateOptions = {
    'heat_sensitive': 'Heat Sensitive',
    'cold_sensitive': 'Cold Sensitive',
    'high_altitude': 'High Altitude',
    'high_humidity': 'High Humidity',
  };

  static const Map<String, String> _healthOptions = {
    'walking_limits': 'Walking Limits',
    'vertigo_heights': 'Vertigo / Heights',
    'respiratory_asthma': 'Respiratory / Asthma',
  };

  final Set<String> _selectedClimate = {};
  final Set<String> _selectedHealth = {};

  // ── 6. AI Notes & Quirks ──────────────────────────────────────────────────
  final TextEditingController _notesController = TextEditingController();
  static const List<String> _quickNotePrompts = [
    'Love local cafes & street food',
    'No morning flights before 9 AM',
    'Prefer boutique stays',
    'Enjoy photography spots',
    'Prefer scenic train routes',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initFromProfile();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _initFromProfile() {
    final profile = context.read<ProfileBloc>().state.profile;

    _selectedTravelStyle = profile?.travelStyle ?? 'Relaxed';
    _selectedPace = profile?.pacePreference?.toLowerCase() ?? 'moderate';
    if (!_pacingOptions.containsKey(_selectedPace)) {
      _selectedPace = 'moderate';
    }

    double rawBudget = profile?.budget ?? 3000.0;
    // If previously saved in USD (e.g. < 400), gracefully scale to INR (min ₹500)
    if (rawBudget < 400.0) {
      rawBudget = (rawBudget * 80).clamp(500.0, 50000.0);
    }
    _dailyBudget = rawBudget;
    _selectedBudgetTier = profile?.budgetTier?.toLowerCase() ?? 'moderate';

    _selectedDiet = profile?.dietaryPreference ?? 'No restrictions';

    // Parse existing health constraints
    if (profile?.healthConstraints != null) {
      profile!.healthConstraints!.forEach((key, val) {
        if (val == true) _selectedHealth.add(key);
      });
    }

    // Parse existing climate sensitivities
    if (profile?.climateSensitivities != null) {
      profile!.climateSensitivities!.forEach((key, val) {
        if (val == true) _selectedClimate.add(key);
      });
    }

    _notesController.text = profile?.rawPreferenceNotes ?? '';
  }

  String _formatRupees(int val) {
    return val.toString().replaceAllMapped(
          RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
          (Match m) => '${m[1]},',
        );
  }

  void _showCustomBudgetDialog() {
    final textController = TextEditingController(text: _dailyBudget.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Enter Custom Budget (₹)',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Specify your daily budget in Indian Rupees. Minimum selectable budget is ₹500/day.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDeepTeal,
                    fontSize: 16,
                  ),
                  hintText: 'e.g. 3500',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primaryDeepTeal, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeepTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final parsed = double.tryParse(textController.text.trim());
                if (parsed != null && parsed >= 500) {
                  setState(() {
                    _dailyBudget = parsed;
                    if (parsed < 1500) {
                      _selectedBudgetTier = 'backpacker';
                    } else if (parsed <= 5000) {
                      _selectedBudgetTier = 'moderate';
                    } else {
                      _selectedBudgetTier = 'luxury';
                    }
                  });
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Minimum selectable budget is ₹500/day.',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Set Budget'),
            ),
          ],
        );
      },
    );
  }

  void _appendQuickPrompt(String prompt) {
    final current = _notesController.text.trim();
    if (current.isEmpty) {
      _notesController.text = prompt;
    } else if (!current.contains(prompt)) {
      _notesController.text = '$current. $prompt';
    }
    setState(() {});
  }

  Future<void> _savePreferences() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final profileBloc = context.read<ProfileBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final token = await ServiceLocator.authLocalDataSource.getToken();

    if (token != null && token.isNotEmpty && mounted) {
      final healthMap = <String, dynamic>{
        for (final k in _healthOptions.keys) k: _selectedHealth.contains(k),
      };

      final climateMap = <String, dynamic>{
        for (final k in _climateOptions.keys) k: _selectedClimate.contains(k),
      };

      profileBloc.add(
        ProfileUpdateRequested(
          token: token,
          travelStyle: _selectedTravelStyle,
          pacePreference: _selectedPace,
          budget: _dailyBudget,
          budgetTier: _selectedBudgetTier,
          dietaryPreference: _selectedDiet,
          healthConstraints: healthMap,
          climateSensitivities: climateMap,
          rawPreferenceNotes: _notesController.text.trim(),
        ),
      );
    }

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Preferences saved immediately!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDeepTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.profile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final authUser = context.watch<AuthBloc>().state.user;
    final profileUser = context.watch<ProfileBloc>().state.updatedUser ?? authUser;

    final String displayName = (profileUser?.fullName != null && profileUser!.fullName!.isNotEmpty)
        ? profileUser.fullName!
        : ((profileUser?.username != null && profileUser!.username!.isNotEmpty)
            ? profileUser.username!
            : 'Traveler');

    final String displayHandle = (profileUser?.username != null && profileUser!.username!.isNotEmpty)
        ? '@${profileUser.username}'
        : '@traveler';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: Stack(
          children: [
            // ── 1. Scrollable Form Content ──────────────────────────────────
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                top: topPadding + 88,
                bottom: bottomPadding + 104, // Guarantees zero overlap with sticky CTA
                left: 18,
                right: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // User Summary Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryDeepTeal,
                          ),
                          child: Center(
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'W',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              Text(
                                displayHandle,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Dimension 1: Travel Style / Vibe ──────────────────────
                  _buildSectionCard(
                    title: 'Travel Style & Vibe',
                    subtitle: 'Choose your primary way of exploring destinations.',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _travelStyles.map((style) {
                        final isSelected = _selectedTravelStyle == style;
                        return _buildSelectableChip(
                          label: style,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() => _selectedTravelStyle = style);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Dimension 2: Trip Pacing ──────────────────────────────
                  _buildSectionCard(
                    title: 'Trip Pacing',
                    subtitle: 'Sets the rhythm for group activities and daily itineraries.',
                    child: Column(
                      children: _pacingOptions.entries.map((entry) {
                        final isSelected = _selectedPace == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPace = entry.key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentWarmYellow
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accentWarmYellow.withValues(alpha: 0.38),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 19,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight:
                                            isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Dimension 3: Daily Budget in INR (₹) ───────────────────
                  _buildSectionCard(
                    title: 'Daily Budget (₹)',
                    subtitle: 'Estimated spending per day in Indian Rupees (min ₹500/day).',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preset Tier Chips
                        Semantics(
                          container: true,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _budgetTiers.map((tierData) {
                              final tierKey = tierData['tier'] as String;
                              final label = tierData['label'] as String;
                              final defaultVal = tierData['defaultVal'] as double;
                              final isSelected = _selectedBudgetTier == tierKey;

                              return _buildSelectableChip(
                                label: label,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedBudgetTier = tierKey;
                                    _dailyBudget = defaultVal;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Spend readout & slider
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Daily Budget',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${_formatRupees(_dailyBudget.toInt())}/day',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDeepTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Custom Price Tap Button
                                  InkWell(
                                    onTap: _showCustomBudgetDialog,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentWarmYellow
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppColors.accentWarmYellow),
                                      ),
                                      child: Text(
                                        'Custom',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ExcludeSemantics(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppColors.primaryDeepTeal,
                                    inactiveTrackColor: const Color(0xFFCBD5E1),
                                    thumbColor: AppColors.accentWarmYellow,
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _dailyBudget.clamp(500.0, 25000.0),
                                    min: 500.0,
                                    max: 25000.0,
                                    divisions: 49, // Steps of ₹500
                                    onChanged: (val) {
                                      setState(() {
                                        _dailyBudget = val;
                                        if (val < 1500) {
                                          _selectedBudgetTier = 'backpacker';
                                        } else if (val <= 5000) {
                                          _selectedBudgetTier = 'moderate';
                                        } else {
                                          _selectedBudgetTier = 'luxury';
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Min: ₹500',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₹25,000+',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 16),

                  // ── Dimension 4: Dietary Requirements ─────────────────────
                  _buildSectionCard(
                    title: 'Dietary Requirements',
                    subtitle: 'Strict union logic ensures meals accommodate everyone.',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _dietaryOptions.map((diet) {
                        final isSelected = _selectedDiet == diet;
                        return _buildSelectableChip(
                          label: diet,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() => _selectedDiet = diet);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Dimension 5: Health & Climate Needs (USP) ─────────────
                  _buildSectionCard(
                    title: 'Health & Climate Needs',
                    subtitle: 'Helps AI filter out high-strain activities and rough weather.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Climate Sensitivities',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _climateOptions.entries.map((entry) {
                            final isSelected = _selectedClimate.contains(entry.key);
                            return _buildSelectableChip(
                              label: entry.value,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedClimate.remove(entry.key);
                                  } else {
                                    _selectedClimate.add(entry.key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Mobility & Physical Constraints',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _healthOptions.entries.map((entry) {
                            final isSelected = _selectedHealth.contains(entry.key);
                            return _buildSelectableChip(
                              label: entry.value,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedHealth.remove(entry.key);
                                  } else {
                                    _selectedHealth.add(entry.key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Dimension 6: AI Notes & Quirks ────────────────────────
                  _buildSectionCard(
                    title: 'AI Travel Notes & Quirks',
                    subtitle: 'Converts into a 384-dimensional vector embedding for group matchmaking.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Love hidden local cafes, prefer late check-ins, dislike night flights...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.primaryDeepTeal,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Quick Suggestions (Tap to add):',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickNotePrompts.map((prompt) {
                            return ActionChip(
                              label: Text(
                                prompt,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onPressed: () => _appendQuickPrompt(prompt),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Fixed Top Header (Unified WeTravelScreenHeader) ───────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: WeTravelScreenHeader(
                title: 'My Preferences',
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Back',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.profile);
                    }
                  },
                ),
                showMenuButton: false,
              ),
            ),

            // ── 3. Sticky Bottom CTA (Zero Overlap with Scrollable Content) ─
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  bottomPadding > 0 ? bottomPadding + 8 : 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _savePreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDeepTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Save Preferences',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
            title,
            style: GoogleFonts.inter(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDeepTeal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentWarmYellow : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentWarmYellow.withValues(alpha: 0.38),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
