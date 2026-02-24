import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/home/presentation/providers/home_provider.dart';
import 'package:speech_coach/shared/widgets/app_card.dart';

class DailyChallengesSection extends StatelessWidget {
  final List<DailyChallenge> challenges;

  const DailyChallengesSection({
    super.key,
    required this.challenges,
  });

  Color _categoryColor(String category) {
    return switch (category) {
      'Presentations' => AppColors.categoryPresentations,
      'Interviews' => AppColors.categoryInterviews,
      'Public Speaking' => AppColors.categoryPublicSpeaking,
      'Conversations' => AppColors.categoryConversations,
      'Debates' => AppColors.categoryDebates,
      'Storytelling' => AppColors.categoryStorytelling,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Challenges',
              style: AppTypography.headlineSmall(),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: AppTypography.bodyMedium(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...challenges.map(
          (challenge) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChallengeCard(
              challenge: challenge,
              categoryColor: _categoryColor(challenge.category),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final Color categoryColor;

  const _ChallengeCard({
    required this.challenge,
    required this.categoryColor,
  });

  IconData get _categoryIcon {
    switch (challenge.category) {
      case 'Presentations':
        return Icons.slideshow_rounded;
      case 'Storytelling':
        return Icons.auto_stories_rounded;
      case 'Debates':
        return Icons.forum_rounded;
      case 'Interviews':
        return Icons.work_outline_rounded;
      case 'Conversations':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.mic_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        context.push(
          '/session/setup/${Uri.encodeComponent(challenge.category)}',
          extra: {'prompt': challenge.description},
        );
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _categoryIcon,
              color: categoryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppTypography.titleMedium(),
                ),
                const SizedBox(height: 2),
                Text(
                  challenge.description,
                  style: AppTypography.bodySmall(
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${challenge.durationMinutes}m',
              style: AppTypography.labelMedium(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
