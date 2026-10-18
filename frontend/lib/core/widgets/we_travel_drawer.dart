import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../router/route_names.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// Premium sidebar navigation drawer for WeTravel.
/// Provides streamlined access to primary screens, active trip workspace,
/// itineraries, expenses, user preferences, and profile.
class WeTravelDrawer extends StatelessWidget {
  const WeTravelDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userName = 'Alex Morgan';
    String userEmail = 'alex.morgan@wetravel.app';

    if (authState is AuthAuthenticatedState) {
      if (authState.user.fullName != null &&
          authState.user.fullName!.isNotEmpty) {
        userName = authState.user.fullName!;
      }
      userEmail = authState.user.email;
    }

    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drawer Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Logo
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF004E64),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.send_rounded,
                                color: Color(0xFFF59E0B),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'WeTravel',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004E64),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF64748B), size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // User Info Card
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.profile);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF004E64),
                                width: 1.5,
                              ),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/avatar_user.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        userName,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'PRO',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
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
                ],
              ),
            ),

            // ── Navigation List ────────────────────────────────────────
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  _buildSectionHeader('MAIN NAVIGATION'),
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentPath == RouteNames.home,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.home);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.map_outlined,
                    label: 'My Trips',
                    isSelected: currentPath == RouteNames.trips,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.trips);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.mail_outline_rounded,
                    label: 'Friends & Inbox',
                    isSelected: currentPath == RouteNames.friends,
                    badgeCount: 2,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.friends);
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildSectionHeader('ACTIVE TRIP: GOA WEEKEND'),
                  _DrawerItem(
                    icon: Icons.space_dashboard_rounded,
                    label: 'Trip Workspace',
                    isSelected: currentPath.contains('goa-weekend') &&
                        !currentPath.contains('itinerary') &&
                        !currentPath.contains('expenses'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.tripDetailsPath('goa-weekend'));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Trip Itinerary',
                    isSelected: currentPath.contains('itinerary'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.itineraryPath('goa-weekend'));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Trip Expenses',
                    isSelected: currentPath.contains('expenses'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.expensesPath('goa-weekend'));
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildSectionHeader('PREFERENCES & SETTINGS'),
                  _DrawerItem(
                    icon: Icons.tune_rounded,
                    label: 'Travel Preferences',
                    isSelected: currentPath == RouteNames.myPreferences ||
                        currentPath == RouteNames.preferences,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.myPreferences);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile & Settings',
                    isSelected: currentPath == RouteNames.profile,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.profile);
                    },
                  ),

                  const SizedBox(height: 16),
                  // "+ Plan New Trip" CTA inside Drawer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteNames.createTrip);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        'Plan New Trip',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Drawer Footer ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF0D9488),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI Group Engine Active',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F2C3F),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _confirmLogout(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBA1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6, top: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of WeTravel?',
          style: GoogleFonts.inter(color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF004E64);
    final inactiveColor = const Color(0xFF475569);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F3F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          size: 22,
          color: isSelected ? activeColor : inactiveColor,
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? activeColor : const Color(0xFF0F172A),
          ),
        ),
        trailing: badgeCount != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            : (isSelected
                ? const Icon(Icons.check_circle_rounded,
                    size: 16, color: Color(0xFF004E64))
                : null),
      ),
    );
  }
}
