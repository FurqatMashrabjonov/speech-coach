import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/shared/widgets/app_card.dart';

class ContinuePracticeCard extends StatelessWidget {
  final String? lastCategory;
  final VoidCallback? onTap;

  const ContinuePracticeCard({
    super.key,
    this.lastCategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lastCategory == null) return const SizedBox.shrink();

    return AppCard(
      onTap: onTap,
      backgroundColor: AppColors.lavender.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Practice',
                  style: AppTypography.titleLarge(),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    lastCategory!,
                    style: AppTypography.labelMedium(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}
