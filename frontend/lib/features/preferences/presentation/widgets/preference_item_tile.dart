import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable list tile for individual preference entries on the "My Preferences" screen.
/// Matches the WeTravel design with mint circular icon container, deep teal title,
/// cyan/slate value indicator, and right-pointing chevron.
class PreferenceItemTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final String? value;
  final Widget? customValueWidget;
  final VoidCallback? onTap;

  const PreferenceItemTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.value,
    this.customValueWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF004E64).withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Mint Circular Icon Container ─────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFDEF2F1), // Soft mint / light teal
                shape: BoxShape.circle,
              ),
              child: Center(child: leadingIcon),
            ),
            const SizedBox(width: 14),

            // ── Title & Value Column ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF004E64),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (customValueWidget != null)
                    customValueWidget!
                  else if (value != null)
                    Text(
                      value!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF007791),
                      ),
                    ),
                ],
              ),
            ),

            // ── Chevron Right ────────────────────────────────────────
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF004E64),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
