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
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

/// Production-ready Profile screen with Clean Architecture & BLoC state management.
/// - Fully dynamic: fetches real profile & user data from backend.
/// - Security: zero exposure or rendering of database IDs / UUIDs.
/// - Header: high-contrast, bold "Profile" title with drawer menu (settings icon removed).
/// - Clean composition: explorer tag & 3 stat tabs removed per design spec.
/// - Editable personal information: Full Name, Username, and Phone via interactive modal.
/// - Relocated authentication actions: "Account & Settings" sits below Privacy & Security.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final token = await ServiceLocator.authLocalDataSource.getToken();
    if (token != null && token.isNotEmpty && mounted) {
      context.read<ProfileBloc>().add(ProfileFetchRequested(token: token));
    }
  }

  /// Opens the industry-standard Edit Profile modal bottom sheet.
  void _openEditProfileSheet({
    required String initialFullName,
    required String initialUsername,
    required String initialPhone,
  }) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController(text: initialFullName);
    final usernameController = TextEditingController(
      text: initialUsername.startsWith('@') ? initialUsername.substring(1) : initialUsername,
    );
    final phoneController = TextEditingController(text: initialPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Sheet Title & Close Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Update your personal information visible to your travel groups.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Full Name Field
                    Text(
                      'Full Name',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Suyash Pandey',
                        prefixIcon: const Icon(Icons.person_outline_rounded,
                            color: AppColors.primaryDeepTeal, size: 20),
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
                          borderSide:
                              const BorderSide(color: AppColors.primaryDeepTeal, width: 1.8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Full name cannot be empty.';
                        }
                        if (trimmed.length < 2) {
                          return 'Full name must be at least 2 characters.';
                        }
                        if (trimmed.length > 50) {
                          return 'Full name cannot exceed 50 characters.';
                        }
                        if (!RegExp(r"^[a-zA-Z\s\-'.]+$").hasMatch(trimmed)) {
                          return 'Full name can only contain letters, spaces, hyphens, and dots.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Username Field
                    Text(
                      'Username',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: usernameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'e.g. suyash_p',
                        prefixText: '@',
                        prefixStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeepTeal,
                        ),
                        prefixIcon: const Icon(Icons.alternate_email_rounded,
                            color: AppColors.primaryDeepTeal, size: 19),
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
                          borderSide:
                              const BorderSide(color: AppColors.primaryDeepTeal, width: 1.8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Username cannot be empty.';
                        }
                        if (trimmed.length < 3) {
                          return 'Username must be at least 3 characters.';
                        }
                        if (trimmed.length > 30) {
                          return 'Username cannot exceed 30 characters.';
                        }
                        if (trimmed.contains(' ')) {
                          return 'Username cannot contain spaces.';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(trimmed)) {
                          return 'Only letters, numbers, underscores, and dots are allowed.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Phone Field
                    Text(
                      'Phone Number',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'e.g. +91 98765 43210',
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: AppColors.primaryDeepTeal, size: 20),
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
                          borderSide:
                              const BorderSide(color: AppColors.primaryDeepTeal, width: 1.8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) return null;
                        final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
                        if (digitsOnly.length < 7 ||
                            digitsOnly.length > 15 ||
                            !RegExp(r'^\+?[0-9\s\-()]{7,20}$').hasMatch(trimmed)) {
                          return 'Enter a valid phone number (e.g. +91 98765 43210).';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Actions: Cancel & Save Changes
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting ? null : () => Navigator.of(sheetCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    setSheetState(() => isSubmitting = true);

                                    final profileBloc = this.context.read<ProfileBloc>();
                                    final messenger = ScaffoldMessenger.of(this.context);
                                    final token = await ServiceLocator.authLocalDataSource
                                        .getToken();
                                    if (token != null && token.isNotEmpty && mounted) {
                                      profileBloc.add(
                                        ProfileUpdateRequested(
                                          token: token,
                                          fullName: fullNameController.text.trim(),
                                          username: usernameController.text.trim(),
                                          phone: phoneController.text.trim(),
                                        ),
                                      );
                                    }

                                    if (mounted && sheetCtx.mounted) {
                                      Navigator.of(sheetCtx).pop();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded,
                                                  color: Colors.white, size: 20),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Profile updated successfully!',
                                                style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: AppColors.primaryDeepTeal,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentWarmYellow,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    // Source user data dynamically from ProfileBloc if loaded, fallback to AuthBloc user
    final user = profileState.updatedUser ?? authState.user;
    final profile = profileState.profile;

    final String displayName = (user?.fullName != null && user!.fullName!.isNotEmpty)
        ? user.fullName!
        : ((user?.username != null && user!.username!.isNotEmpty)
            ? user.username!
            : 'Traveler');
    final String displayEmail =
        (user?.email != null && user!.email.isNotEmpty) ? user.email : 'traveler@wetravel.app';
    final String displayUsername = (user?.username != null && user!.username!.isNotEmpty)
        ? user.username!
        : 'traveler';
    final String displayPhone = (user?.phone != null && user!.phone!.isNotEmpty)
        ? user.phone!
        : 'Not provided';

    final String initials = displayName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join();

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
            // ── Scrollable Body with Pull-to-Refresh ───────────────────────
            RefreshIndicator(
              color: AppColors.primaryDeepTeal,
              onRefresh: _fetchProfile,
              edgeOffset: topPadding + 90,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  top: topPadding + 104,
                  bottom: bottomPadding + 32,
                  left: 18,
                  right: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── 1. Avatar & Identity Card ─────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Circular Avatar with Edit Badge
                          GestureDetector(
                            onTap: () => _openEditProfileSheet(
                              initialFullName: displayName,
                              initialUsername: displayUsername,
                              initialPhone: displayPhone == 'Not provided' ? '' : displayPhone,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF004E64), Color(0xFF007791)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: AppColors.accentWarmYellow,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryDeepTeal.withValues(alpha: 0.22),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials.isNotEmpty ? initials : 'WT',
                                      style: GoogleFonts.inter(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentWarmYellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Full Name
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDeepTeal,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Verified Email
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    displayEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF007791),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF10B981),
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── 2. Profile Information Card (Editable) ────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile Information',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _openEditProfileSheet(
                                  initialFullName: displayName,
                                  initialUsername: displayUsername,
                                  initialPhone: displayPhone == 'Not provided' ? '' : displayPhone,
                                ),
                                icon: const Icon(Icons.edit_outlined,
                                    size: 16, color: AppColors.accentWarmYellow),
                                label: Text(
                                  'Edit',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentWarmYellow,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Full Name Row
                          _buildDetailRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Full Name',
                            value: displayName,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          // Username Row
                          _buildDetailRow(
                            icon: Icons.alternate_email_rounded,
                            label: 'Username',
                            value: '@$displayUsername',
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          // Phone Row
                          _buildDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone Number',
                            value: displayPhone,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          // Email Row (Read-Only)
                          _buildDetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: displayEmail,
                            isReadOnly: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── 3. AI Travel Preferences Card (Dynamic via BLoC) ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'My Travel Preference',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDeepTeal,
                                    ),
                                  ),
                                  if (profileState.isLoading) ...[
                                    const SizedBox(width: 8),
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryDeepTeal,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () => context.push(RouteNames.myPreferences),
                                icon: const Icon(Icons.tune_rounded,
                                    size: 15, color: AppColors.primaryDeepTeal),
                                label: Text(
                                  'Adjust',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeepTeal,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildDetailRow(
                            icon: Icons.explore_outlined,
                            label: 'Travel Style',
                            value: profile?.travelStyle ?? 'Cultural & Local',
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          _buildDetailRow(
                            icon: Icons.restaurant_outlined,
                            label: 'Dietary Preference',
                            value: profile?.dietaryPreference ?? 'No restrictions',
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          _buildDetailRow(
                            icon: Icons.payments_outlined,
                            label: 'Daily Budget',
                            value: profile?.budget != null
                                ? '₹${profile!.budget!.toInt()}/day'
                                : (profile?.budgetTier ?? 'Moderate (₹3,000/day)'),
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          _buildDetailRow(
                            icon: Icons.speed_rounded,
                            label: 'Trip Pace',
                            value: () {
                              final p = profile?.pacePreference?.toLowerCase();
                              if (p == 'slow') return 'Chill & Leisurely';
                              if (p == 'fast') return 'Action-Packed';
                              return 'Balanced';
                            }(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── 4. Settings & Options ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildOptionTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Trip Notifications',
                            subtitle: 'Poll alerts, chat & itinerary updates',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Notification preferences are enabled for active trips.',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                  ),
                                  backgroundColor: AppColors.primaryDeepTeal,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                          ),
                          const Divider(
                              height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
                          _buildOptionTile(
                            icon: Icons.security_rounded,
                            title: 'Privacy & Security Policy',
                            subtitle: 'Read our data encryption and zero-trust policy',
                            onTap: () => context.push(RouteNames.privacyPolicy),
                          ),
                          const Divider(
                              height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
                          _buildOptionTile(
                            icon: Icons.manage_accounts_outlined,
                            title: 'Account & Settings',
                            subtitle: 'Account details, log out & account deletion',
                            onTap: () => context.push(RouteNames.accountSettings),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Version Footer
                    Text(
                      'WeTravel • Secure Travel Platform v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Fixed Top Header (Unified WeTravelScreenHeader) ───────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const WeTravelScreenHeader(
                title: 'Profile',
                showMenuButton: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isReadOnly = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryDeepTeal, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
            ],
          ),
        ),
        if (isReadOnly) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Verified',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryDeepTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryDeepTeal, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDeepTeal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Color(0xFF94A3B8)),
      onTap: onTap,
    ),
  );
}
}
