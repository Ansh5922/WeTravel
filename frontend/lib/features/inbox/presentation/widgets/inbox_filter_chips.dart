import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum InboxFilterTab {
  all,
  pending,
  accepted,
  declined,
}

/// Filter chips for the Inbox screen matching the exact UI styling of My Trips filter chips:
/// - Rounded pill shapes (border radius 20)
/// - Selected: Deep teal background (#004E64) with white text and translucent white count pill
/// - Unselected: Soft slate background (#F1F5F9) with muted text and grey count pill
/// - Smooth tap animation and horizontal scrolling
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
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            tab: InboxFilterTab.all,
            label: 'All',
            count: allCount,
          ),
          _buildChip(
            tab: InboxFilterTab.pending,
            label: 'Pending',
            count: pendingCount,
          ),
          _buildChip(
            tab: InboxFilterTab.accepted,
            label: 'Accepted',
            count: acceptedCount,
          ),
          _buildChip(
            tab: InboxFilterTab.declined,
            label: 'Declined',
            count: declinedCount,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required InboxFilterTab tab,
    required String label,
    required int count,
  }) {
    final isSelected = selectedTab == tab;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF004E64) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
