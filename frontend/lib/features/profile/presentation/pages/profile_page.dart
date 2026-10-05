import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../trips/presentation/widgets/invite_screen_decorations.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Screen displaying the user's saved profile information, travel statistics,
/// account details, preferences access, and a confirmation-backed Logout button.
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004E64),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of WeTravel? You will need to sign in again to access your trips.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              if (mounted) {
                context.go(RouteNames.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    final String? rawFullName = user?.fullName;
    final String? rawUsername = user?.username;
    final String displayName = (rawFullName != null && rawFullName.isNotEmpty)
        ? rawFullName
        : ((rawUsername != null && rawUsername.isNotEmpty) ? rawUsername : 'Suyash Pandey');
    final String displayEmail = (user != null && user.email.isNotEmpty) ? user.email : 'suyash@wetravel.app';
    final String displayPhone = (user?.phone != null && user!.phone!.isNotEmpty) ? user.phone! : '+91 98765 43210';
    final String initials = displayName.split(' ').where((s) => s.isNotEmpty).map((s) => s[0]).take(2).join();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Profile Body ────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 64,
              bottom: bottomPadding + 32,
              left: 18,
              right: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // ── Avatar & Name Card ──────────────────────────────
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
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF004E64), Color(0xFF007791)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF004E64).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials.isNotEmpty ? initials : 'SP',
                                style: GoogleFonts.inter(
                                  fontSize: 32,
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
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF007791),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF2F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Explorer • Group Lead',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Travel Stats Row ─────────────────────────────────
                Row(
                  children: [
                    _buildStatCard('3', 'Active Trips', Icons.flight_takeoff_rounded),
                    const SizedBox(width: 10),
                    _buildStatCard('14', 'Places Visited', Icons.place_rounded),
                    const SizedBox(width: 10),
                    _buildStatCard('8', 'Collaborators', Icons.group_rounded),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Personal Info Details Card ───────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Username',
                        value: (rawUsername != null && rawUsername.isNotEmpty) ? '@$rawUsername' : '@suyash_p',
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: displayPhone,
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Member ID',
                        value: (user != null && user.id.isNotEmpty)
                            ? (user.id.length >= 8 ? user.id.substring(0, 8) : user.id)
                            : 'WT-2026-94',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Live AI Travel Preferences Card (BLoC Connected) ────
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    final profile = profileState.profile;
                    final travelStyle = profile?.travelStyle ?? 'Cultural & Local';
                    final dietary = profile?.dietaryPreference ?? 'No restrictions';
                    final budget = profile?.budget != null ? '\$${profile!.budget!.toInt()}/day' : (profile?.budgetTier ?? 'Moderate (\$150/day)');
                    final pace = profile?.pacePreference ?? 'Balanced';

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'AI Travel Preferences',
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const Spacer(),
                              if (profileState.isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004E64)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            icon: Icons.explore_outlined,
                            label: 'Travel Style',
                            value: travelStyle,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _buildInfoRow(
                            icon: Icons.restaurant_outlined,
                            label: 'Dietary',
                            value: dietary,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _buildInfoRow(
                            icon: Icons.attach_money_rounded,
                            label: 'Daily Budget',
                            value: budget,
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          _buildInfoRow(
                            icon: Icons.speed_rounded,
                            label: 'Trip Pace',
                            value: pace,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ── Settings & Actions ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.tune_rounded,
                        title: 'My Travel Preferences',
                        subtitle: 'Pacing, food, stays, & activities',
                        onTap: () => context.push(RouteNames.myPreferences),
                      ),
                      const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
                      _buildSettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Trip Notifications',
                        subtitle: 'Poll alerts, chat & itinerary updates',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 60, endIndent: 16, color: Color(0xFFF1F5F9)),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy & Security',
                        subtitle: 'Account details and session settings',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Logout Button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _confirmLogout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: const Color(0xFFFEF2F2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'WeTravel v1.0.0 (Build 2026.10)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Top Header ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, topPadding + 58),
                  painter: InviteHeaderPainter(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 4,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Profile',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF004E64), size: 20),
            const SizedBox(height: 6),
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004E64),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF007791)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF004E64),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFDEF2F1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF004E64), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF004E64),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
      ),
    );
  }
}
