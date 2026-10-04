import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum InboxFilterTab {
  all,
  pending,
  accepted,
  declined,
}

class InboxFilterChips extends StatelessWidget {
  final InboxFilterTab selectedTab;
  final ValueChanged<InboxFilterTab> onTabChanged;
  final int allCount;
  final int pendingCount;
  final int acceptedCount;
  final int declinedCount;

  const InboxFilterChips({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.allCount,
    required this.pendingCount,
    required this.acceptedCount,
    required this.declinedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            tab: InboxFilterTab.all,
            label: 'All ($allCount)',
          ),
          const SizedBox(width: 8),
          _buildChip(
            tab: InboxFilterTab.pending,
            label: 'Pending ($pendingCount)',
          ),
          const SizedBox(width: 8),
          _buildChip(
            tab: InboxFilterTab.accepted,
            label: 'Accepted ($acceptedCount)',
          ),
          const SizedBox(width: 8),
          _buildChip(
            tab: InboxFilterTab.declined,
            label: 'Declined ($declinedCount)',
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required InboxFilterTab tab,
    required String label,
  }) {
    final isSelected = selectedTab == tab;

    return GestureDetector(
      onTap: () => onTabChanged(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004E64) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF004E64) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF004E64).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
