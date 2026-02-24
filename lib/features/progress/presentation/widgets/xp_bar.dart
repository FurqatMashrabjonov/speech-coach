import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';

class XpBar extends ConsumerWidget {
  const XpBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.secondary.withValues(alpha: 0.14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Lv.${progress.level}',
                  style: AppTypography.labelMedium(color: AppColors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                progress.levelTitle,
                style: AppTypography.titleMedium(),
              ),
              const Spacer(),
              Text(
                '${progress.totalXp} XP',
                style: AppTypography.labelMedium(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: context.divider,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.levelProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                      .animate()
                      .scaleX(
                        begin: 0,
                        end: 1,
                        alignment: Alignment.centerLeft,
                        duration: 800.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${progress.xpForNextLevel - progress.totalXp} XP to Level ${progress.level + 1}',
            style: AppTypography.labelSmall(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
