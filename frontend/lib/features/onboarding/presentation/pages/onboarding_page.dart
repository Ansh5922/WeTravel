import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_visual_one.dart';
import '../widgets/onboarding_visual_two.dart';
import '../widgets/onboarding_visual_three.dart';

/// Data model representing a single onboarding slide.
class _OnboardingSlideData {
  final String title;
  final String description;
  final Widget visual;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.visual,
  });
}

/// WeTravel 3-step collaborative onboarding experience.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      title: 'Plan together.',
      description:
          "Bring everyone's ideas, preferences, and plans into one shared trip.",
      visual: OnboardingVisualOne(),
    ),
    _OnboardingSlideData(
      title: 'Your trip. Your way.',
      description:
          "WeTravel uses everyone's preferences to help create a plan that works for the whole group.",
      visual: OnboardingVisualTwo(),
    ),
    _OnboardingSlideData(
      title: 'More exploring. Less planning.',
      description:
          'Collaborate on activities, itineraries, polls, expenses, and memories — all in one place.',
      visual: OnboardingVisualThree(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(RouteNames.signup);
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onSkip() {
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // ── Top Bar: Back & Skip Navigation ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentIndex > 0
                            ? IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: AppColors.primaryDeepTeal,
                                ),
                                onPressed: _onBack,
                                tooltip: 'Back',
                              )
                            : const SizedBox(width: 44),
                        if (!isLastPage)
                          TextButton(
                            onPressed: _onSkip,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: Text(
                              'Skip',
                              style: AppTypography.titleSmall(
                                color: AppColors.textSecondary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          )
                        else
                          const SizedBox(width: 44),
                      ],
                    ),
                  ),
                ),

                // ── Carousel Content (PageView) ──────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Center(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1. Large Visual Area
                              slide.visual,

                              const SizedBox(height: AppSpacing.lg),

                              // 2. Editorial Heading (Playfair Display)
                              Text(
                                slide.title,
                                textAlign: TextAlign.center,
                                style: AppTypography.displayMedium(
                                  color: AppColors.primaryDeepTeal,
                                ).copyWith(
                                  fontSize: 28,
                                  letterSpacing: -0.4,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // 3. Supporting Description (Inter)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyLarge(
                                    color: AppColors.textSecondary,
                                  ).copyWith(
                                    height: 1.48,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Bottom Section: Page Indicator & Action Controls ──────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator dots/pill
                      OnboardingPageIndicator(
                        count: _slides.length,
                        currentIndex: _currentIndex,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Primary Action CTA
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDeepTeal,
                            foregroundColor: AppColors.surfaceWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: AppTypography.labelLarge(
                              color: AppColors.surfaceWhite,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Secondary Option (Only on final slide)
                      if (isLastPage) ...[
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: () => context.go(RouteNames.login),
                            child: Text(
                              'Already have an account? Log in',
                              style: AppTypography.bodySmall(
                                color: AppColors.secondaryTeal,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 40),
                      ],
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
