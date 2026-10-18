import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Production-ready modern search bar matching the WeTravel design language.
/// 
/// Solves the cramped typing area and bulky borders by offering:
/// - Comfortable 48dp height with vertically centered input alignment.
/// - Borderless, clean card elevation with soft ambient drop-shadow.
/// - Automatic reactive clear button via [ValueListenableBuilder].
/// - Optional matching filter action button with active badge indicator.
class WeTravelSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final String hintText;
  final bool showFilterButton;
  final bool hasActiveFilter;
  final double height;
  final FocusNode? focusNode;
  final bool autofocus;

  const WeTravelSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.hintText = 'Search...',
    this.showFilterButton = true,
    this.hasActiveFilter = false,
    this.height = 48,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Main Search Bar Field ──────────────────────────────────────────
        Expanded(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.isNotEmpty;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            splashRadius: 18,
                            onPressed: () {
                              controller.clear();
                              if (onChanged != null) {
                                onChanged!('');
                              }
                              if (onClear != null) {
                                onClear!();
                              }
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Optional Matching Filter Button ────────────────────────────────
        if (showFilterButton && onFilterTap != null) ...[
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: height,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: hasActiveFilter
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF004E64),
                      size: 22,
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        top: 10,
                        right: 10,
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
              ),
            ),
          ),
        ],
      ],
    );
  }
}
