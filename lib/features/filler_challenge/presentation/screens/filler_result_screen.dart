import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/filler_challenge/presentation/providers/filler_challenge_provider.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class FillerResultScreen extends ConsumerWidget {
  const FillerResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fillerChallengeProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Tappable(
            onTap: () => context.go('/home'),
            child: Text('No results', style: AppTypography.headlineSmall()),
          ),
        ),
      );
    }

    final isNewBest = result.survivalSeconds >= state.personalBest &&
        state.personalBest > 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
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
                  Text(
                    'Challenge Complete',
                    style: AppTypography.headlineSmall(),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Survival time
                    Text(
                      '${result.survivalSeconds}s',
                      style: AppTypography.displayLarge(
                        color: AppColors.primary,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.7, 0.7)),
                    const SizedBox(height: 4),
                    Text(
                      result.totalFillers == 0
                          ? 'Filler-free!'
                          : 'until first filler',
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    if (isNewBest) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'New Personal Best!',
                          style: AppTypography.labelMedium(
                            color: AppColors.success,
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    ],
                    const SizedBox(height: 32),

                    // Stats
                    Row(
                      children: [
                        _StatTile(
                          label: 'Total Fillers',
                          value: '${result.totalFillers}',
                          color: result.totalFillers > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        _StatTile(
                          label: 'Personal Best',
                          value: '${state.personalBest}s',
                          color: AppColors.primary,
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    const SizedBox(height: 20),

                    // Breakdown
                    if (result.breakdown.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filler Breakdown',
                              style: AppTypography.titleMedium(),
                            ),
                            const SizedBox(height: 12),
                            ...result.breakdown.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      '"${e.key}"',
                                      style: AppTypography.bodyMedium(),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.14),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${e.value}x',
                                        style: AppTypography.labelMedium(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: context.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Tappable(
                      onTap: () {
                        Share.share(
                          'I survived ${result.survivalSeconds}s without filler words '
                          'in the Speechy AI Filler Challenge!'
                          'Can you beat my score?',
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.share_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Share',
                              style: AppTypography.button(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Tappable(
                      onTap: () {
                        ref.read(fillerChallengeProvider.notifier).reset();
                        context.go('/filler-challenge');
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            'Try Again',
                            style:
                                AppTypography.button(color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineMedium(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
