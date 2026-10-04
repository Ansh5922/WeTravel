import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable section card for travel preferences with icon, title, and interactive pill options.
class PreferencesCategoryCard extends StatelessWidget {
  final Widget? iconWidget;
  final IconData? icon;
  final String title;
  final List<String> options;
  final Set<String> selectedOptions;
  final ValueChanged<String> onOptionToggled;
  final bool isMultiSelect;

  const PreferencesCategoryCard({
    super.key,
    this.iconWidget,
    this.icon,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onOptionToggled,
    this.isMultiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (Icon + Title) ──────────────────────────────────
          Row(
            children: [
              if (iconWidget != null)
                iconWidget!
              else if (icon != null)
                Icon(
                  icon,
                  color: const Color(0xFF004E64),
                  size: 24,
                ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004E64),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Pill Options ───────────────────────────────────────────
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);

              return GestureDetector(
                onTap: () => onOptionToggled(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFCBD5E1),
                      width: 1.1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF004E64),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
