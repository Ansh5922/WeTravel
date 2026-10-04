import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom bottom navigation bar matching WeTravel's design:
/// Home, Trips, Center Add (+) FAB, Inbox (with notification dot), and Profile.
class WeTravelBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddTap;

  const WeTravelBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding : 10,
        left: 12,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home
          _NavBarItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),

          // 2. Trips
          _NavBarItem(
            icon: Icons.map_outlined,
            label: 'Trips',
            isSelected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),

          // 3. Center FAB (+)
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55F59E0B),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // 4. Inbox (with orange notification badge dot)
          _NavBarItem(
            icon: Icons.mail_outline_rounded,
            label: 'Inbox',
            isSelected: currentIndex == 2,
            hasBadge: true,
            onTap: () => onTabSelected(2),
          ),

          // 5. Profile
          _NavBarItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFFF59E0B);
    const unselectedColor = Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                if (hasBadge)
                  Positioned(
                    top: -1,
                    right: -3,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
