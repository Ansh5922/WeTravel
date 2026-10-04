import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Floating pill-shaped search bar with destination search hint and filter controls.
class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const HomeSearchBar({
    super.key,
    this.onTap,
    this.onFilterTap,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: controller != null
                ? TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search trips, destinations or invite links...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Search trips, destinations or invite links...',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.tune_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
