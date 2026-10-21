import 'package:flutter/material.dart';
import '../../../../core/widgets/we_travel_screen_header.dart';
import '../../../../core/widgets/we_travel_search_bar.dart';

/// Standard top header for the Inbox screen.
/// Uses the unified [WeTravelScreenHeader] with dark teal curved wave design,
/// dynamic invitation count, and responsive search bar.
class InboxHeader extends StatelessWidget {
  final int pendingCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback? onScanTap;
  final bool hasActiveFilter;

  const InboxHeader({
    super.key,
    required this.pendingCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.onScanTap,
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WeTravelScreenHeader(
          title: 'Inbox',
          showMenuButton: false,
        ),
        Container(
          color: const Color(0xFFFAF9F6),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: WeTravelSearchBar(
            controller: searchController,
            hintText: 'Search trips, destinations, members...',
            hasActiveFilter: hasActiveFilter,
            onChanged: onSearchChanged,
            onClear: () {
              searchController.clear();
              onSearchChanged('');
            },
            onFilterTap: onFilterTap,
          ),
        ),
      ],
    );
  }
}
