import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Represents a single filter chip option with optional count badge and icon.
class FilterChipItem<T> {
  final T value;
  final String label;
  final int? count;
  final IconData? icon;

  const FilterChipItem({
    required this.value,
    required this.label,
    this.count,
    this.icon,
  });
}

/// A unified, modular horizontal filter chip bar matching WeTravel's design system:
/// - Smooth horizontal scrolling
/// - Selected state: Deep teal (#004E64) with white text & translucent count badge
/// - Unselected state: Soft background (#F1F5F9) with slate border & neutral count badge
/// - Type-safe generic value T for clean modular integration across all screens
class WeTravelFilterChips<T> extends StatelessWidget {
  final List<FilterChipItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const WeTravelFilterChips({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: items.map((item) {
            final isSelected = item.value == selectedValue;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelected(item.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF004E64)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF004E64)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                      if (item.count != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.22)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.count}',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
