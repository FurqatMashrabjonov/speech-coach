import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';

class FeedbackSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool isPositive;

  const FeedbackSection({
    super.key,
    required this.title,
    required this.items,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isPositive
        ? AppColors.success.withValues(alpha: 0.08)
        : AppColors.gold.withValues(alpha: 0.14);
    final iconColor = isPositive ? AppColors.success : AppColors.gold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.check_circle_rounded
                    : Icons.trending_up_rounded,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.titleLarge()),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
