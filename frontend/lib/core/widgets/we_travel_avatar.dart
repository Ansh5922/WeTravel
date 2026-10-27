import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Production-ready circular avatar widget for WeTravel.
/// Supports remote CDN network URLs, local base64 Data URIs,
/// initials fallback, and an optional edit/camera badge.
class WeTravelAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final double borderWidth;
  final Color? borderColor;

  const WeTravelAvatar({
    super.key,
    this.avatarUrl,
    required this.initials,
    this.size = 88,
    this.onTap,
    this.showEditBadge = false,
    this.borderWidth = 2.5,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.accentWarmYellow;
    final cleanInitials = initials.trim().isNotEmpty ? initials.trim() : 'WT';

    Widget avatarContent;
    final url = avatarUrl?.trim();

    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:image')) {
        try {
          final base64String = url.split(',').last;
          final bytes = base64Decode(base64String);
          avatarContent = Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildInitialsFallback(cleanInitials),
          );
        } catch (_) {
          avatarContent = _buildInitialsFallback(cleanInitials);
        }
      } else {
        avatarContent = Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitialsFallback(cleanInitials),
        );
      }
    } else {
      avatarContent = _buildInitialsFallback(cleanInitials);
    }

    final avatarCircle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF004E64), Color(0xFF007791)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeepTeal.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: avatarContent),
    );

    if (!showEditBadge && onTap == null) {
      return avatarCircle;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCircle,
          if (showEditBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: AppColors.accentWarmYellow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: size * 0.18,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialsFallback(String text) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
