import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/daily_goal/presentation/providers/daily_goal_provider.dart';
import 'package:speech_coach/shared/widgets/duo_button.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  static const _categories = [
    ('Presentations', Icons.slideshow_rounded, AppColors.cardPeach),
    ('Interviews', Icons.work_outline_rounded, AppColors.cardBlue),
    ('Public Speaking', Icons.campaign_rounded, AppColors.cardLavender),
    ('Conversations', Icons.chat_bubble_outline_rounded, AppColors.cardMint),
    ('Debates', Icons.forum_rounded, AppColors.cardYellow),
    ('Storytelling', Icons.auto_stories_rounded, AppColors.cardRose),
    ('Phone Anxiety', Icons.phone_in_talk_rounded, AppColors.cardPeach),
    ('Dating & Social', Icons.favorite_outline_rounded, AppColors.cardBlue),
    ('Conflict & Boundaries', Icons.shield_outlined, AppColors.cardLavender),
    ('Social Situations', Icons.groups_rounded, AppColors.cardMint),
  ];

  static const _categoryCounts = {
    'Presentations': 5,
    'Interviews': 5,
    'Public Speaking': 5,
    'Conversations': 5,
    'Debates': 5,
    'Storytelling': 5,
    'Phone Anxiety': 5,
    'Dating & Social': 5,
    'Conflict & Boundaries': 5,
    'Social Situations': 5,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyChallenge = ref.watch(dailyChallengeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice',
                    style: AppTypography.displayMedium(),
                  ),
                  Text(
                    'Choose a category to start',
                    style: AppTypography.bodySmall(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              // Daily Challenge Banner
              if (dailyChallenge != null)
                _DailyChallengeBanner(
                  title: dailyChallenge.title,
                  description: dailyChallenge.description,
                  scenarioId: dailyChallenge.id,
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.05),
              if (dailyChallenge != null) const SizedBox(height: 24),

              // Categories
              Text(
                'Categories',
                style: AppTypography.headlineSmall(),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final (name, icon, color) = _categories[index];
                  final count = _categoryCounts[name] ?? 5;
                  return _CategoryCard(
                    name: name,
                    icon: icon,
                    color: color,
                    count: count,
                    onTap: () => context.push(
                      '/scenarios/${Uri.encodeComponent(name)}',
                    ),
                  );
                },
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeBanner extends StatelessWidget {
  final String title;
  final String description;
  final String scenarioId;

  const _DailyChallengeBanner({
    required this.title,
    required this.description,
    required this.scenarioId,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.push(
        '/scenario/${Uri.encodeComponent(scenarioId)}',
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: AppColors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DAILY CHALLENGE',
                    style: AppTypography.labelSmall(
                      color: AppColors.white,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.headlineSmall(color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            DuoButton(
              text: 'Start Now',
              color: AppColors.white,
              shadowColor: const Color(0xFFE5E5E5),
              onTap: () => context.push(
                '/scenario/${Uri.encodeComponent(scenarioId)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const Spacer(),
            Text(
              name,
              style: AppTypography.labelLarge(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$count scenarios',
              style: AppTypography.labelSmall(
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
