import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';

class ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;
  final Color? color;

  const ScoreCard({
    super.key,
    required this.label,
    required this.score,
    required this.icon,
    this.color,
  });

  Color get _cardColor {
    if (color != null) return color!;
    return switch (label) {
      'Clarity' => AppColors.primary,
      'Pace' => AppColors.skyBlue,
      'Filler Words' => AppColors.secondary,
      'Confidence' => AppColors.lime,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: _cardColor, size: 28),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: AppTypography.headlineLarge(color: _cardColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
