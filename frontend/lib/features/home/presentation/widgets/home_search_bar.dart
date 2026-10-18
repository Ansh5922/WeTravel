import 'package:flutter/material.dart';
import '../../../../core/widgets/we_travel_search_bar.dart';

/// Floating search bar for the Home screen matching the Inbox design language.
/// Provides a comfortable typing field with soft drop-shadow and a dedicated
/// filter button with active state badge indicator.
class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool hasActiveFilter;

  const HomeSearchBar({
    super.key,
    this.onTap,
    this.onFilterTap,
    this.controller,
    this.onChanged,
    this.hasActiveFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return WeTravelSearchBar(
        controller: controller!,
        onChanged: onChanged,
        onFilterTap: onFilterTap,
        hasActiveFilter: hasActiveFilter,
        hintText: 'Search trips, destinations or invite links...',
        height: 48,
      );
    }

    // Static fallback if used as a tap-to-open button
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: WeTravelSearchBar(
        controller: TextEditingController(),
        onFilterTap: onFilterTap,
        hasActiveFilter: hasActiveFilter,
        hintText: 'Search trips, destinations or invite links...',
        height: 48,
      ),
    );
  }
}
