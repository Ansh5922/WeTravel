import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_scenic_decorations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

/// Sticky production-grade top navigation bar for [HomePage].
///
/// Smoothly transitions from transparent with white typography/icons over the scenic
/// hero banner when at the top of the screen (`scrollOffset == 0`), into a solid
/// white elevated app bar with deep teal branding and dark icons when scrolled down.
class HomeStickyTopBar extends StatelessWidget {
  final double scrollOffset;
  final bool showHamburger;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HomeStickyTopBar({
    super.key,
    required this.scrollOffset,
    this.showHamburger = false,
    this.onMenuTap,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Smooth transition from transparent to solid white between 10px and 110px scroll
    final progress = ((scrollOffset - 10) / 100.0).clamp(0.0, 1.0);
    final isScrolled = progress > 0.5;

    // Dynamically update status bar icon brightness (white over dark image, dark over white bar)
    final overlayStyle = isScrolled
        ? SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          );

    final titleColor = Color.lerp(
      Colors.white,
      const Color(0xFF0F2C3F),
      progress,
    )!;

    final iconColor = Color.lerp(
      Colors.white,
      const Color(0xFF0F172A),
      progress,
    )!;

    final avatarBorderColor = Color.lerp(
      Colors.white.withValues(alpha: 0.9),
      const Color(0xFFCBD5E1),
      progress,
    )!;

    final authState = context.watch<AuthBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;
    final user = profileState.updatedUser ?? authState.user;

    final String displayName = (user?.fullName != null && user!.fullName!.isNotEmpty)
        ? user.fullName!
        : ((user?.username != null && user!.username!.isNotEmpty)
            ? user.username!
            : 'Traveler');

    final String initials = displayName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase())
        .take(2)
        .join();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Container(
        padding: EdgeInsets.only(
          top: statusBarHeight + 6,
          left: 20,
          right: 20,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: progress),
          boxShadow: progress > 0.05
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06 * progress),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: progress > 0.95
              ? Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                    width: 0.8,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            if (showHamburger) ...[
              IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: iconColor,
                  size: 26,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Open navigation menu',
                onPressed: onMenuTap ??
                    () {
                      Scaffold.of(context).openDrawer();
                    },
              ),
              const SizedBox(width: 12),
            ],

            // Brand Logo & Name
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomPaint(
                  size: Size(24 * 1.15, 24),
                  painter: PaperPlaneLogoPainter(),
                ),
                const SizedBox(width: 8),
                Text(
                  'WeTravel',
                  style: GoogleFonts.inter(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Notification Bell with Badge Dot
            GestureDetector(
              onTap: onNotificationTap,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: iconColor,
                    size: 26,
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Dynamic User Profile Avatar (matching Profile Screen)
            GestureDetector(
              onTap: onProfileTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: avatarBorderColor,
                    width: 2.0,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004E64), Color(0xFF007791)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : 'WT',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
}
