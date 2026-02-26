import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/feedback/domain/feedback_entity.dart';

class ShareableScoreCard extends StatelessWidget {
  final ConversationFeedback feedback;
  final String scenarioTitle;
  final String category;

  const ShareableScoreCard({
    super.key,
    required this.feedback,
    required this.scenarioTitle,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Speechy AI',
                style: AppTypography.titleMedium(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Score
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${feedback.overallScore}',
                    style: AppTypography.displayLarge(color: AppColors.primary),
                  ),
                  Text(
                    '/100',
                    style: AppTypography.labelSmall(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(scenarioTitle, style: AppTypography.titleMedium()),
          Text(
            category,
            style: AppTypography.labelSmall(color: context.textSecondary),
          ),
          const SizedBox(height: 16),

          // Scores row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniScore(label: 'Clarity', score: feedback.clarity),
              _MiniScore(label: 'Confidence', score: feedback.confidence),
              _MiniScore(label: 'Engagement', score: feedback.engagement),
              _MiniScore(label: 'Relevance', score: feedback.relevance),
            ],
          ),
          const SizedBox(height: 16),

          // Tagline
          Text(
            'Your AI speaking coach that actually talks back',
            style: AppTypography.labelSmall(
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniScore extends StatelessWidget {
  final String label;
  final int score;

  const _MiniScore({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$score',
          style: AppTypography.titleLarge(color: AppColors.primary),
        ),
        Text(
          label,
          style: AppTypography.labelSmall(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
