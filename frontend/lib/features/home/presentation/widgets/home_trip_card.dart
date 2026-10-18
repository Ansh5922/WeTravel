import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/home_trip.dart';
import 'avatar_stack.dart';

/// Reusable trip summary card displaying destination thumbnail, status pill,
/// trip dates, member count, location, and overlapping participant avatars.
/// Supports both [HomeTripEntity] (backend dynamic entity) and legacy [dynamic] models.
class HomeTripCard extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
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
    this.imagePath,
    this.imageUrl,
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

  /// Factory constructor taking a [HomeTripEntity] or legacy entity
  factory HomeTripCard.fromEntity({
    Key? key,
    required dynamic trip,
    VoidCallback? onTap,
  }) {
    if (trip is HomeTripEntity) {
      final label = trip.statusLabel.trim();
      final statusLower = label.toLowerCase();

      final Color bg;
      final Color text;
      if (statusLower == 'planning') {
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
      } else if (statusLower == 'ongoing') {
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
      } else if (statusLower == 'completed') {
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
      } else {
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
      }

      // Assign realistic avatars for members
      final List<String> avatarsList = [];
      const fallbackAvatars = [
        'assets/images/avatar_user.jpg',
        'assets/images/avatar_1.jpg',
        'assets/images/avatar_2.jpg',
        'assets/images/avatar_devansh.jpg',
        'assets/images/avatar_neha.jpg',
      ];
      final count = trip.members.isNotEmpty
          ? trip.members.length
          : (trip.memberCount > 0 ? trip.memberCount : 1);
      for (int i = 0; i < count && i < 3; i++) {
        avatarsList.add(fallbackAvatars[i % fallbackAvatars.length]);
      }

      // Determine scenic thumbnail
      String? imagePath;
      String? imageUrl;
      if (trip.coverImageUrl != null && trip.coverImageUrl!.isNotEmpty) {
        if (trip.coverImageUrl!.startsWith('http://') ||
            trip.coverImageUrl!.startsWith('https://')) {
          imageUrl = trip.coverImageUrl;
        } else {
          imagePath = trip.coverImageUrl;
        }
      } else {
        final loc = '${trip.location} ${trip.title}'.toLowerCase();
        if (loc.contains('goa') || loc.contains('beach')) {
          imagePath = 'assets/images/trip_goa.jpg';
        } else if (loc.contains('kerala') || loc.contains('backwater')) {
          imagePath = 'assets/images/trip_kerala.jpg';
        } else if (loc.contains('manali') ||
            loc.contains('mountain') ||
            loc.contains('trek') ||
            loc.contains('himalaya')) {
          imagePath = 'assets/images/trip_manali.jpg';
        } else {
          imagePath = 'assets/images/hero_coast.jpg';
        }
      }

      return HomeTripCard(
        key: key,
        imagePath: imagePath,
        imageUrl: imageUrl,
        title: trip.title,
        statusLabel: trip.statusLabel,
        statusBgColor: bg,
        statusTextColor: text,
        dateText: trip.dateText,
        memberCount: trip.memberCount,
        location: trip.location,
        avatars: avatarsList,
        onTap: onTap,
      );
    }

    // Support legacy TripSummaryItem
    final bool isPlanning =
        trip.statusLabel.toString().toLowerCase() == 'planning';
    return HomeTripCard(
      key: key,
      imagePath: trip.imagePath as String?,
      title: trip.title as String,
      statusLabel: trip.statusLabel as String,
      statusBgColor:
          isPlanning ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
      statusTextColor:
          isPlanning ? const Color(0xFF0284C7) : const Color(0xFFD97706),
      dateText: trip.dateText as String,
      memberCount: trip.memberCount as int,
      location: trip.location as String,
      avatars: List<String>.from(trip.avatars as Iterable),
      onTap: onTap,
    );
  }

  Widget _buildThumbnail() {
    if (imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'))) {
      return Image.network(
        imageUrl!,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackAssetImage(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 92,
            height: 92,
            color: const Color(0xFFF1F5F9),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    return _buildFallbackAssetImage();
  }

  Widget _buildFallbackAssetImage() {
    final asset = (imagePath != null && imagePath!.isNotEmpty)
        ? imagePath!
        : 'assets/images/hero_coast.jpg';
    return Image.asset(
      asset,
      width: 92,
      height: 92,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 92,
        height: 92,
        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
        alignment: Alignment.center,
        child: const Icon(
          Icons.landscape_rounded,
          color: Color(0xFF0F766E),
          size: 36,
        ),
      ),
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
                  child: _buildThumbnail(),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (statusLabel.toLowerCase() == 'ongoing') ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF15803D),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  statusLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: statusTextColor,
                                  ),
                                ),
                              ],
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
                              '$dateText  •  $memberCount ${memberCount == 1 ? "member" : "members"}',
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

/// Clean skeleton card representing a loading trip item.
class HomeTripCardSkeleton extends StatelessWidget {
  const HomeTripCardSkeleton({super.key});

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
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Skeleton
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),

          // Content Column Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 110,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 58,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
