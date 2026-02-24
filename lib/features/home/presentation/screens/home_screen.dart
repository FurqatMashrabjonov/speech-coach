import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/paywall/data/usage_service.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/progress/presentation/widgets/xp_bar.dart';
import 'package:speech_coach/features/scenarios/presentation/providers/scenario_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categories = [
    ('Interviews', Icons.work_outline_rounded, AppColors.categoryInterviews),
    ('Presentations', Icons.slideshow_rounded, AppColors.categoryPresentations),
    ('Public Speaking', Icons.campaign_rounded, AppColors.categoryPublicSpeaking),
    ('Conversations', Icons.chat_bubble_outline_rounded, AppColors.categoryConversations),
    ('Debates', Icons.forum_rounded, AppColors.categoryDebates),
    ('Storytelling', Icons.auto_stories_rounded, AppColors.categoryStorytelling),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final usageService = ref.watch(usageServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SpeechMaster',
                        style: AppTypography.displayMedium(),
                      ),
                      Text(
                        'Your AI speaking coach',
                        style: AppTypography.bodySmall(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Streak badge
                  Tappable(
                    onTap: () => context.go('/progress'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${progress.streak}',
                            style: AppTypography.titleMedium(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              // XP Bar
              const XpBar()
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 16),

              // Free tier indicator
              if (!usageService.isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${usageService.remainingSessions} free sessions remaining today',
                        style: AppTypography.bodySmall(
                          color: context.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Tappable(
                        onTap: () => context.push('/paywall'),
                        child: Text(
                          'Upgrade',
                          style: AppTypography.labelMedium(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 20),

              // Quick start card
              _QuickStartCard()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Categories
              Text(
                'Practice Scenarios',
                style: AppTypography.headlineSmall(),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: 4),
              Text(
                'Choose a category to start practicing',
                style: AppTypography.bodySmall(
                  color: context.textSecondary,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: 16),

              // Category list
              ...List.generate(_categories.length, (index) {
                final (name, icon, color) = _categories[index];
                final scenarios = ref.read(scenariosByCategoryProvider(name));
                return _CategoryTile(
                  name: name,
                  icon: icon,
                  color: color,
                  scenarioCount: scenarios.length,
                  onTap: () {
                    context.push(
                      '/scenarios/${Uri.encodeComponent(name)}',
                    );
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 300 + (index * 50)),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.05);
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStartCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tappable(
      onTap: () {
        _showQuickStartSheet(context, ref);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.22),
              AppColors.secondary.withValues(alpha: 0.22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.record_voice_over_rounded,
                color: AppColors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Practice',
                    style: AppTypography.titleLarge(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Free-form AI conversation',
                    style: AppTypography.bodySmall(
                      color: context.textSecondary,
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
      ),
    );
  }

  void _showQuickStartSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _QuickStartCategorySheet(),
    );
  }
}

class _QuickStartCategorySheet extends StatelessWidget {
  static const _categories = [
    ('Presentations', Icons.slideshow_rounded, AppColors.categoryPresentations),
    ('Interviews', Icons.work_outline_rounded, AppColors.categoryInterviews),
    ('Public Speaking', Icons.campaign_rounded, AppColors.categoryPublicSpeaking),
    ('Conversations', Icons.chat_bubble_outline_rounded, AppColors.categoryConversations),
    ('Debates', Icons.forum_rounded, AppColors.categoryDebates),
    ('Storytelling', Icons.auto_stories_rounded, AppColors.categoryStorytelling),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quick Practice',
            style: AppTypography.headlineSmall(),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a free-form voice conversation',
            style: AppTypography.bodySmall(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final (name, icon, color) = _categories[index];
              return Tappable(
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/conversation/${Uri.encodeComponent(name)}',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: AppTypography.labelSmall(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 180, height: 28),
                  const SizedBox(height: 8),
                  const SkeletonLine(width: 140, height: 14),
                ],
              ),
              const SkeletonCircle(size: 36),
            ],
          ),
          const SizedBox(height: 20),
          // XP bar
          Skeleton(height: 56, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 20),
          // Quick start
          Skeleton(height: 92, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 24),
          // Categories title
          const SkeletonLine(width: 160, height: 20),
          const SizedBox(height: 16),
          // Category tiles
          for (int i = 0; i < 4; i++) ...[
            Skeleton(height: 80, borderRadius: BorderRadius.circular(16)),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int scenarioCount;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.scenarioCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.divider,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.titleMedium()),
                  Text(
                    '$scenarioCount scenarios',
                    style: AppTypography.bodySmall(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
