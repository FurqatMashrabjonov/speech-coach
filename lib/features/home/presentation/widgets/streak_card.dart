import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/shared/widgets/app_card.dart';

class StreakCard extends StatelessWidget {
  final int streak;
  final int totalSessions;

  const StreakCard({
    super.key,
    required this.streak,
    required this.totalSessions,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Streak!',
                  style: AppTypography.headlineMedium(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalSessions sessions completed',
                  style: AppTypography.bodyMedium(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    7,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: index < streak
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: index < streak
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}
