import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'avatar_stack.dart';

/// Reusable trip summary card displaying destination thumbnail, status pill,
/// trip dates, member count, location, and overlapping participant avatars.
class HomeTripCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String statusLabel;
  final Color statusBgColor;
  final Color statusTextColor;
  final String dateText;
  final int memberCount;
  final String location;
  final List<String> avatars;
  final VoidCallback? onTap;

  const HomeTripCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.statusLabel,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.dateText,
    required this.memberCount,
    required this.location,
    required this.avatars,
    this.onTap,
  });

  /// Preset for Goa Getaway (Upcoming)
  factory HomeTripCard.goaGetaway({
    Key? key,
    VoidCallback? onTap,
  }) {
    return HomeTripCard(
      key: key,
      imagePath: 'assets/images/trip_goa.jpg',
      title: 'Goa Getaway',
      statusLabel: 'Upcoming',
      statusBgColor: const Color(0xFFFEF3C7),
      statusTextColor: const Color(0xFFD97706),
      dateText: '12 – 15 Oct 2026',
      memberCount: 4,
      location: 'Goa, India',
      avatars: const [
        'assets/images/avatar_1.jpg',
        'assets/images/avatar_2.jpg',
        'assets/images/avatar_user.jpg',
      ],
      onTap: onTap,
    );
  }

  /// Preset for Kerala Escape (Planning)
  factory HomeTripCard.keralaEscape({
    Key? key,
    VoidCallback? onTap,
  }) {
    return HomeTripCard(
      key: key,
      imagePath: 'assets/images/trip_kerala.jpg',
      title: 'Kerala Escape',
      statusLabel: 'Planning',
      statusBgColor: const Color(0xFFE0F2FE),
      statusTextColor: const Color(0xFF0284C7),
      dateText: 'May 2026',
      memberCount: 3,
      location: 'Kerala, India',
      avatars: const [
        'assets/images/avatar_2.jpg',
        'assets/images/avatar_user.jpg',
        'assets/images/avatar_1.jpg',
      ],
      onTap: onTap,
    );
  }

  /// Factory constructor taking a TripSummaryItem entity
  factory HomeTripCard.fromEntity({
    Key? key,
    required dynamic trip,
    VoidCallback? onTap,
  }) {
    final bool isPlanning = trip.statusLabel.toString().toLowerCase() == 'planning';
    return HomeTripCard(
      key: key,
      imagePath: trip.imagePath as String,
      title: trip.title as String,
      statusLabel: trip.statusLabel as String,
      statusBgColor: isPlanning ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
      statusTextColor: isPlanning ? const Color(0xFF0284C7) : const Color(0xFFD97706),
      dateText: trip.dateText as String,
      memberCount: trip.memberCount as int,
      location: trip.location as String,
      avatars: List<String>.from(trip.avatars as Iterable),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imagePath,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),

                // Trip Information Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Status Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: statusTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Dates & Member Count
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '$dateText  •  $memberCount members',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Location & Chevron
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFF0D9488),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF0D9488),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Overlapping Member Avatars
                      AvatarStack(
                        avatarPaths: avatars,
                        size: 24,
                        overlap: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
