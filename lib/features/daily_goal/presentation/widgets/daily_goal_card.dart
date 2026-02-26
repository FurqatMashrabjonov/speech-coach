import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/daily_goal/presentation/providers/daily_goal_provider.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(dailyGoalProvider);
    final challenge = ref.watch(dailyChallengeProvider);

    return Tappable(
      onTap: () {
        if (challenge != null) {
          context.push('/scenario/${Uri.encodeComponent(challenge.id)}');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: goal.isComplete
                ? [
                    AppColors.success.withValues(alpha: 0.18),
                    AppColors.success.withValues(alpha: 0.08),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.secondary.withValues(alpha: 0.12),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Circular progress ring
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: goal.progress,
                      strokeWidth: 5,
                      backgroundColor: context.divider,
                      color: goal.isComplete
                          ? AppColors.success
                          : AppColors.primary,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  if (goal.isComplete)
                    Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 28,
                    )
                  else
                    Text(
                      '${goal.completedToday}/${goal.targetSessions}',
                      style: AppTypography.titleMedium(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.isComplete
                        ? 'Done for today!'
                        : 'Daily Goal',
                    style: AppTypography.titleLarge(
                      color: goal.isComplete
                          ? AppColors.success
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (!goal.isComplete && challenge != null)
                    Text(
                      'Challenge: ${challenge.title}',
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else if (goal.isComplete)
                    Text(
                      'Great work! Come back tomorrow.',
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                    )
                  else
                    Text(
                      'Complete ${goal.targetSessions} session today',
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (!goal.isComplete)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
