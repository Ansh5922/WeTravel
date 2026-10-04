import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable selectable card tile representing trip categories
/// (Vacation, Adventure, Food, Cultural).
class TripTypeTile extends StatelessWidget {
  final String label;
  final Widget Function(Color color)? iconBuilder;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TripTypeTile({
    super.key,
    required this.label,
    this.iconBuilder,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isSelected ? const Color(0xFF0F172A) : const Color(0xFF005F73);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 88,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFAB82A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFE89A15) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0xFFFAB82A).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
                child: Center(
                  child: iconBuilder != null ? iconBuilder!(activeColor) : icon,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: activeColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

