import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_coach/app/constants/app_constants.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pageColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.lime,
  ];

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.mic_rounded,
      title: 'Practice Speaking',
      description:
          'Record yourself speaking on various topics and get instant AI-powered feedback.',
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'Get AI Feedback',
      description:
          'Receive detailed analysis on clarity, pace, filler words, and overall delivery.',
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'Track Progress',
      description:
          'Watch your speaking skills improve over time with detailed progress tracking.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar + Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _pages.length,
                        minHeight: 4,
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTypography.bodyMedium(color: context.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final color = _pageColors[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Icon(
                            page.icon,
                            color: color,
                            size: 64,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 400.ms,
                            ),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          style: AppTypography.displaySmall(),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: AppTypography.bodyLarge(
                            color: context.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
