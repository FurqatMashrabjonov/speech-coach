import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/features/speaker_dna/domain/speaker_dna_entity.dart';

class DNAShareCard extends StatelessWidget {
  final SpeakerDNA dna;

  const DNAShareCard({super.key, required this.dna});

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
            Icons.fingerprint_rounded,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'My Speaker DNA',
            style: AppTypography.labelMedium(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dna.archetype,
            style: AppTypography.headlineMedium(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            dna.archetypeDescription,
            style: AppTypography.bodySmall(),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat('Clarity', dna.clarity),
              const SizedBox(width: 16),
              _MiniStat('Confidence', dna.confidence),
              const SizedBox(width: 16),
              _MiniStat('Engagement', dna.engagement),
              const SizedBox(width: 16),
              _MiniStat('Relevance', dna.relevance),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Speaks like ${dna.famousSpeakerMatch}',
            style: AppTypography.labelSmall(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SpeechMaster',
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
  final String label;
  final int value;

  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTypography.titleMedium(color: AppColors.primary),
        ),
        Text(
          label.substring(0, 3),
          style: AppTypography.labelSmall(
            color: const Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}
