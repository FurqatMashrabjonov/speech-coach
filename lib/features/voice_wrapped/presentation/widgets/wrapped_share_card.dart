import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/features/voice_wrapped/domain/voice_wrapped_entity.dart';

class WrappedShareCard extends StatelessWidget {
  final VoiceWrapped wrapped;

  const WrappedShareCard({super.key, required this.wrapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            '${wrapped.monthName} Voice Wrapped',
            style: AppTypography.headlineSmall(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat('${wrapped.totalMinutes}', 'min'),
              _MiniStat('${wrapped.sessionsCompleted}', 'sessions'),
              _MiniStat('${wrapped.averageScore}', 'avg score'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              wrapped.monthArchetype,
              style: AppTypography.titleMedium(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Speechy AI',
            style: AppTypography.labelSmall(
              color: const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleLarge(color: AppColors.primary),
        ),
        Text(
          label,
          style: AppTypography.labelSmall(
            color: const Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
