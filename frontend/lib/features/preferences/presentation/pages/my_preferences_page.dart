import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../trips/presentation/widgets/invite_screen_decorations.dart';
import '../../domain/entities/user_travel_preferences.dart';
import '../widgets/preference_item_tile.dart';

/// "My Preferences" screen matching the WeTravel design screenshot.
/// Displays user profile details, grouped preference summary cards with
/// custom icons, quick inline editing, and a primary deep teal Save button.
class MyPreferencesPage extends StatefulWidget {
  const MyPreferencesPage({super.key});

  @override
  State<MyPreferencesPage> createState() => _MyPreferencesPageState();
}

class _MyPreferencesPageState extends State<MyPreferencesPage> {
  UserTravelPreferences _preferences = const UserTravelPreferences();

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Preferences saved to your profile!',
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
  }

  void _showEditSheet(String title, List<String> options, String currentValue, ValueChanged<String> onSelected) {
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
                  'Select $title',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const SizedBox(height: 14),
                ...options.map((option) {
                  final isSelected = option == currentValue;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF004E64) : const Color(0xFF334155),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF004E64))
                        : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
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

                // ── 1. User Profile Header ─────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          _preferences.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF004E64),
                            child: const Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _preferences.userName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _preferences.userHeadline,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _preferences.userBio,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 2. Primary Preferences Card ────────────────────────
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
                    children: [
                      // Travel style
                      PreferenceItemTile(
                        leadingIcon: const Icon(
                          Icons.beach_access_rounded,
                          color: Color(0xFF004E64),
                          size: 22,
                        ),
                        title: 'Travel style',
                        value: _preferences.travelStyle,
                        onTap: () {
                          _showEditSheet(
                            'Travel Style',
                            ['Relaxed', 'Balanced', 'Adventurous'],
                            _preferences.travelStyle,
                            (val) => setState(() => _preferences = _preferences.copyWith(travelStyle: val)),
                          );
                        },
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 70),

                      // Budget comfort
                      PreferenceItemTile(
                        leadingIcon: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFF004E64),
                          size: 22,
                        ),
                        title: 'Budget comfort',
                        value: _preferences.budgetComfort,
                        onTap: () {
                          _showEditSheet(
                            'Budget Comfort',
                            ['Under ₹10k', '₹10k – ₹20k', '₹20k – ₹30k', '₹30k – ₹50k', '₹50k+'],
                            _preferences.budgetComfort,
                            (val) => setState(() => _preferences = _preferences.copyWith(budgetComfort: val)),
                          );
                        },
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 70),

                      // Interests
                      PreferenceItemTile(
                        leadingIcon: const Icon(
                          Icons.cases_rounded,
                          color: Color(0xFF004E64),
                          size: 22,
                        ),
                        title: 'Interests',
                        customValueWidget: Row(
                          children: [
                            const Icon(Icons.restaurant_rounded, color: Color(0xFF007791), size: 15),
                            const SizedBox(width: 4),
                            Text(
                              'Food',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF007791),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.account_balance_rounded, color: Color(0xFF007791), size: 15),
                            const SizedBox(width: 4),
                            Text(
                              'Culture',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF007791),
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final result = await context.push<UserTravelPreferences>(RouteNames.preferences);
                          if (result != null) {
                            setState(() {
                              _preferences = _preferences.copyWith(
                                travelStyle: result.travelStyle,
                                interests: result.interests,
                                foodPreference: result.foodPreference,
                                specialRequirements: result.specialRequirements,
                                additionalNotes: result.additionalNotes,
                              );
                            });
                          }
                        },
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 70),

                      // Food preferences
                      PreferenceItemTile(
                        leadingIcon: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: Color(0xFF004E64),
                          size: 22,
                        ),
                        title: 'Food preferences',
                        value: _preferences.foodPreference,
                        onTap: () {
                          _showEditSheet(
                            'Food Preference',
                            ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Jain'],
                            _preferences.foodPreference,
                            (val) => setState(() => _preferences = _preferences.copyWith(foodPreference: val)),
                          );
                        },
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 70),

                      // Things to avoid
                      PreferenceItemTile(
                        leadingIcon: const Icon(
                          Icons.block_rounded,
                          color: Color(0xFF004E64),
                          size: 22,
                        ),
                        title: 'Things to avoid',
                        value: _preferences.thingsToAvoid,
                        onTap: () {
                          _showEditSheet(
                            'Things to Avoid',
                            ['Early starts', 'Crowded places', 'Long treks', 'Night journeys', 'Spicy food'],
                            _preferences.thingsToAvoid,
                            (val) => setState(() => _preferences = _preferences.copyWith(thingsToAvoid: val)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 3. Availability Card ───────────────────────────────
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
                  child: PreferenceItemTile(
                    leadingIcon: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF004E64),
                      size: 22,
                    ),
                    title: 'Availability',
                    value: _preferences.availability,
                    onTap: () {
                      _showEditSheet(
                        'Availability',
                        ['All days', 'Weekends only', 'Weekdays only', 'Custom dates'],
                        _preferences.availability,
                        (val) => setState(() => _preferences = _preferences.copyWith(availability: val)),
                      );
                    },
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
                    right: 16,
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
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'My Preferences',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Edit Button
                      GestureDetector(
                        onTap: () async {
                          final result = await context.push<UserTravelPreferences>(RouteNames.preferences);
                          if (result != null) {
                            setState(() {
                              _preferences = _preferences.copyWith(
                                travelStyle: result.travelStyle,
                                interests: result.interests,
                                foodPreference: result.foodPreference,
                                specialRequirements: result.specialRequirements,
                                additionalNotes: result.additionalNotes,
                              );
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                    backgroundColor: const Color(0xFF004E64), // Deep Teal matching screenshot
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
