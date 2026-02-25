import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/sharing/data/share_service.dart';
import 'package:speech_coach/features/voice_wrapped/domain/voice_wrapped_entity.dart';
import 'package:speech_coach/features/voice_wrapped/presentation/providers/voice_wrapped_provider.dart';
import 'package:speech_coach/features/voice_wrapped/presentation/widgets/wrapped_share_card.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class VoiceWrappedScreen extends ConsumerStatefulWidget {
  const VoiceWrappedScreen({super.key});

  @override
  ConsumerState<VoiceWrappedScreen> createState() =>
      _VoiceWrappedScreenState();
}

class _VoiceWrappedScreenState extends ConsumerState<VoiceWrappedScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wrapped = ref.watch(voiceWrappedProvider);

    if (wrapped == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No data for last month',
                style: AppTypography.headlineSmall(),
              ),
              const SizedBox(height: 16),
              Tappable(
                onTap: () => context.go('/home'),
                child: Text(
                  'Go Home',
                  style: AppTypography.labelLarge(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Tappable(
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.close_rounded, size: 24),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _Slide1(wrapped: wrapped),
                  _Slide2(wrapped: wrapped),
                  _Slide3(wrapped: wrapped),
                  _Slide4(wrapped: wrapped),
                  _Slide5(
                    wrapped: wrapped,
                    onShare: () => _share(wrapped),
                  ),
                ],
              ),
            ),
            // Page indicators
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.primary
                          : context.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(VoiceWrapped wrapped) async {
    final controller = ScreenshotController();
    final image = await controller.captureFromWidget(
      WrappedShareCard(wrapped: wrapped),
      context: context,
    );
    await ShareService.shareScoreCardImage(
      imageBytes: image,
      scenarioTitle: '${wrapped.monthName} Voice Wrapped',
      overallScore: wrapped.averageScore,
    );
  }
}

class _Slide1 extends StatelessWidget {
  final VoiceWrapped wrapped;
  const _Slide1({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_rounded,
            color: AppColors.primary,
            size: 48,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            'You spoke for',
            style: AppTypography.bodyLarge(color: context.textSecondary),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            '${wrapped.totalMinutes} minutes',
            style: AppTypography.displayMedium(color: AppColors.primary),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 8),
          Text(
            'in ${wrapped.monthName}',
            style: AppTypography.bodyLarge(color: context.textSecondary),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _Slide2 extends StatelessWidget {
  final VoiceWrapped wrapped;
  const _Slide2({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    final improvementText = wrapped.scoreImprovement > 0
        ? '+${wrapped.scoreImprovement.toStringAsFixed(0)}%'
        : '${wrapped.scoreImprovement.toStringAsFixed(0)}%';
    return _SlideBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up_rounded,
            color: AppColors.success,
            size: 48,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            '${wrapped.sessionsCompleted} sessions',
            style: AppTypography.displayMedium(color: AppColors.primary),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 8),
          Text(
            'completed',
            style: AppTypography.bodyLarge(color: context.textSecondary),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 20),
          if (wrapped.scoreImprovement != 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: wrapped.scoreImprovement > 0
                    ? AppColors.success.withValues(alpha: 0.14)
                    : AppColors.error.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score $improvementText vs last month',
                style: AppTypography.labelLarge(
                  color: wrapped.scoreImprovement > 0
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _Slide3 extends StatelessWidget {
  final VoiceWrapped wrapped;
  const _Slide3({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.gold,
            size: 48,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            'Your best category',
            style: AppTypography.bodyLarge(color: context.textSecondary),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            wrapped.bestCategory,
            style: AppTypography.displayMedium(color: AppColors.primary),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 8),
          Text(
            '${wrapped.categoryCounts[wrapped.bestCategory] ?? 0} sessions',
            style: AppTypography.bodyMedium(color: context.textSecondary),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _Slide4 extends StatelessWidget {
  final VoiceWrapped wrapped;
  const _Slide4({required this.wrapped});

  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.accent,
            size: 48,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            'This month you were',
            style: AppTypography.bodyLarge(color: context.textSecondary),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            wrapped.monthArchetype,
            style: AppTypography.displayMedium(color: AppColors.primary),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        ],
      ),
    );
  }
}

class _Slide5 extends StatelessWidget {
  final VoiceWrapped wrapped;
  final VoidCallback onShare;
  const _Slide5({required this.wrapped, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return _SlideBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  '${wrapped.monthName} Recap',
                  style: AppTypography.headlineSmall(),
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                    'Minutes spoken', '${wrapped.totalMinutes}'),
                _SummaryRow(
                    'Sessions', '${wrapped.sessionsCompleted}'),
                _SummaryRow('Avg score', '${wrapped.averageScore}/100'),
                _SummaryRow('Archetype', wrapped.monthArchetype),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 24),
          Tappable(
            onTap: onShare,
            child: Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.share_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Share My Wrapped',
                    style: AppTypography.button(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium(
            color: context.textSecondary,
          )),
          Text(value, style: AppTypography.titleMedium()),
        ],
      ),
    );
  }
}

class _SlideBase extends StatelessWidget {
  final Widget child;
  const _SlideBase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(child: child),
    );
  }
}
