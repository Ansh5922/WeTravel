import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable action card used for "Create a Trip" and "Join a Trip".
class HomeActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color titleColor;
  final Color subtitleColor;
  final Color chevronColor;
  final VoidCallback? onTap;

  const HomeActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.gradient,
    this.titleColor = const Color(0xFF1E293B),
    this.subtitleColor = const Color(0xFF475569),
    this.chevronColor = const Color(0xFF1E293B),
    this.onTap,
  });

  /// Factory constructor for the orange "Create a Trip" card.
  factory HomeActionCard.createTrip({
    Key? key,
    VoidCallback? onTap,
  }) {
    return HomeActionCard(
      key: key,
      title: 'Create a Trip',
      subtitle: 'Plan your dream getaway\nwith your group',
      icon: Icons.add_rounded,
      iconColor: const Color(0xFFF57C00),
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFFA100),
          Color(0xFFFFB300),
          Color(0xFFFFC043),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      titleColor: const Color(0xFF1E293B),
      subtitleColor: const Color(0xFF334155),
      chevronColor: const Color(0xFF1E293B),
      onTap: onTap,
    );
  }

  /// Factory constructor for the light mint "Join a Trip" card.
  factory HomeActionCard.joinTrip({
    Key? key,
    VoidCallback? onTap,
  }) {
    return HomeActionCard(
      key: key,
      title: 'Join a Trip',
      subtitle: 'Have an invite link?\nJoin your friends',
      icon: Icons.group_rounded,
      iconColor: const Color(0xFF0F766E),
      backgroundColor: const Color(0xFFEAF8F7),
      titleColor: const Color(0xFF0F172A),
      subtitleColor: const Color(0xFF475569),
      chevronColor: const Color(0xFF0F766E),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Circular White Icon Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Card Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: subtitleColor,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: chevronColor,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
