import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';

class ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final int maxScore;
  final Color? color;
  final int animationDelay;

  const ScoreBar({
    super.key,
    required this.label,
    required this.score,
    this.maxScore = 10,
    this.color,
    this.animationDelay = 0,
  });

  Color get _scoreColor {
    if (color != null) return color!;
    if (score >= 8) return AppColors.success;
    if (score >= 5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelMedium(
                  color: context.textSecondary,
                ),
              ),
              Text(
                '$score/$maxScore',
                style: AppTypography.titleMedium(color: _scoreColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: context.divider,
                  ),
                  FractionallySizedBox(
                    widthFactor: score / maxScore,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _scoreColor,
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
                        delay: Duration(milliseconds: 300 + animationDelay),
                        curve: Curves.easeOutCubic,
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
