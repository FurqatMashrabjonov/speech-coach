import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${progress.streak} Day Streak',
                style: AppTypography.titleMedium(),
              ),
              Text(
                progress.streak > 0
                    ? 'Keep it up!'
                    : 'Start practicing today!',
                style: AppTypography.bodySmall(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${progress.totalSessions}',
            style: AppTypography.displaySmall(color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          Text(
            'sessions',
            style: AppTypography.labelSmall(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
