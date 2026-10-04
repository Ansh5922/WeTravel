import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/travel_emblem.dart';

/// WeTravel Splash Screen.
///
/// Introduces WeTravel with an editorial, premium travel aesthetic,
/// combining refined serif brand typography, a high-craft collaborative
/// journey emblem, and a subtle AI-assisted travel badge.
class SplashPage extends StatefulWidget {
  final Duration? autoNavigateDelay;

  const SplashPage({
    super.key,
    this.autoNavigateDelay = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _emblemFade;
  late final Animation<Offset> _emblemSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _aiBadgeFade;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // 1. Emblem: fades in and floats up gently
    _emblemFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _emblemSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
    ));

    // 2. WeTravel Title: follows immediately
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.70, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.75, curve: Curves.easeOutCubic),
    ));

    // 3. Tagline: appears smoothly
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.85, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.20),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.90, curve: Curves.easeOutCubic),
    ));

    // 4. AI-Powered indicator badge: soft reveal
    _aiBadgeFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    // Timed transition to Onboarding
    if (widget.autoNavigateDelay != null) {
      _navigationTimer = Timer(widget.autoNavigateDelay!, () {
        if (mounted) {
          context.go(RouteNames.onboarding);
        }
      });
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: SizedBox.expand(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── 1. Minimal Collaborative Journey Emblem ────────────────
                    SlideTransition(
                      position: _emblemSlide,
                      child: FadeTransition(
                        opacity: _emblemFade,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return TravelEmblem(
                              size: isCompact ? 72.0 : 86.0,
                              animationProgress: _controller.value,
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? AppSpacing.md : AppSpacing.lg),

                    // ── 2. Primary Title: "WeTravel" (Playfair Display) ────────
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge(
                            color: AppColors.primaryDeepTeal,
                          ).copyWith(
                            fontSize: isCompact ? 34 : 42,
                            letterSpacing: -0.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── 3. Editorial Tagline (Inter) ──────────────────────────
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Plan together. Travel better.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge(
                            color: AppColors.textSecondary,
                          ).copyWith(
                            fontSize: isCompact ? 14 : 16,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),

                    // ── 4. Intelligent AI Micro-Badge ─────────────────────────
                    FadeTransition(
                      opacity: _aiBadgeFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.aiPillBackground,
                          borderRadius: AppRadius.chip,
                          border: Border.all(
                            color: AppColors.aiCardBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                color: AppColors.accentWarmYellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'AI-Assisted Group Journeys',
                              style: AppTypography.labelSmall(
                                color: const Color(0xFF6B4500),
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
