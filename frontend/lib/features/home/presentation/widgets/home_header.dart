import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top scenic hero header with brand bar, notification bell, profile avatar,
/// and inspirational greeting.
class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background Hero Image
        Container(
          height: 250 + statusBarHeight,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/hero_coast.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.40),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.50),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // Header Content
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + 8,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand & Profile Bar
                Row(
                  children: [
                    // Brand Logo & Name
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: 0.7,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Color(0xFFF59E0B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'WeTravel',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Notification Bell with Badge Dot
                    GestureDetector(
                      onTap: onNotificationTap,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          Positioned(
                            top: 1,
                            right: 1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF59E0B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // User Profile Picture
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/avatar_user.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Hero Greeting Title
                Text(
                  'Your next adventure',
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'is waiting',
                      style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.wb_sunny_rounded,
                      color: Color(0xFFF59E0B),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Hero Subtitle
                Text(
                  'Plan. Collaborate. Explore.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.92),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
