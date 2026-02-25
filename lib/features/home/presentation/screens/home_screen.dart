import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/history/presentation/providers/session_history_provider.dart';
import 'package:speech_coach/features/history/domain/session_history_entity.dart';
import 'package:speech_coach/features/paywall/data/usage_service.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/progress/presentation/widgets/xp_bar.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';
import 'package:speech_coach/features/scenarios/presentation/providers/scenario_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const _categories = [
    ('Interviews', Icons.work_outline_rounded, AppColors.categoryInterviews),
    ('Presentations', Icons.slideshow_rounded, AppColors.categoryPresentations),
    ('Public Speaking', Icons.campaign_rounded, AppColors.categoryPublicSpeaking),
    ('Conversations', Icons.chat_bubble_outline_rounded, AppColors.categoryConversations),
    ('Debates', Icons.forum_rounded, AppColors.categoryDebates),
    ('Storytelling', Icons.auto_stories_rounded, AppColors.categoryStorytelling),
    ('Phone Anxiety', Icons.phone_in_talk_rounded, AppColors.categoryPhoneAnxiety),
    ('Dating & Social', Icons.favorite_outline_rounded, AppColors.categoryDating),
    ('Conflict & Boundaries', Icons.shield_outlined, AppColors.categoryConflict),
    ('Social Situations', Icons.groups_rounded, AppColors.categorySocial),
  ];

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

bool _isWrappedAvailable(UserProgress progress) {
  final now = DateTime.now();
  if (now.day > 7) return false;
  final lastMonth = now.month > 1
      ? DateTime(now.year, now.month - 1)
      : DateTime(now.year - 1, 12);
  return progress.sessionHistory.any(
      (s) => s.date.year == lastMonth.year && s.date.month == lastMonth.month);
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionHistoryProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final usageService = ref.watch(usageServiceProvider);
    final historyState = ref.watch(sessionHistoryProvider);

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

              // Voice Wrapped banner (days 1-7 of month)
              if (_isWrappedAvailable(progress))
                _WrappedBanner()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
              if (_isWrappedAvailable(progress))
                const SizedBox(height: 12),

              // Quick start card
              _QuickStartCard()
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 12),

              // Filler Word Challenge
              _FillerChallengeCard()
                  .animate()
                  .fadeIn(delay: 210.ms, duration: 400.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 24),

              // Recent sessions
              if (historyState.status == SessionHistoryStatus.loaded &&
                  historyState.sessions.isNotEmpty)
                _RecentSessionsSection(
                  sessions: historyState.sessions.take(3).toList(),
                )
                    .animate()
                    .fadeIn(delay: 220.ms, duration: 400.ms)
                    .slideY(begin: 0.1),
              if (historyState.status == SessionHistoryStatus.loaded &&
                  historyState.sessions.isNotEmpty)
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
              ...List.generate(HomeScreen._categories.length, (index) {
                final (name, icon, color) = HomeScreen._categories[index];
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
    ('Phone Anxiety', Icons.phone_in_talk_rounded, AppColors.categoryPhoneAnxiety),
    ('Dating & Social', Icons.favorite_outline_rounded, AppColors.categoryDating),
    ('Conflict & Boundaries', Icons.shield_outlined, AppColors.categoryConflict),
    ('Social Situations', Icons.groups_rounded, AppColors.categorySocial),
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

class _RecentSessionsSection extends StatelessWidget {
  final List<SessionHistoryEntry> sessions;

  const _RecentSessionsSection({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sessions',
              style: AppTypography.headlineSmall(),
            ),
            Tappable(
              onTap: () => context.push('/history'),
              child: Text(
                'See All',
                style: AppTypography.labelMedium(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sessions.map((session) => _RecentSessionTile(session: session)),
      ],
    );
  }
}

class _RecentSessionTile extends StatelessWidget {
  final SessionHistoryEntry session;

  const _RecentSessionTile({required this.session});

  Color get _scoreColor {
    if (session.overallScore >= 80) return AppColors.success;
    if (session.overallScore >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.push('/history/${session.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? context.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.divider, width: 0.5),
        ),
        child: Row(
          children: [
            // Score
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      value: session.overallScore / 100,
                      strokeWidth: 3,
                      backgroundColor: context.divider,
                      color: _scoreColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${session.overallScore}',
                    style: AppTypography.labelMedium(color: _scoreColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.scenarioTitle,
                    style: AppTypography.titleMedium(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(session.createdAt),
                    style: AppTypography.labelSmall(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
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

class _FillerChallengeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.push('/filler-challenge'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.22),
              AppColors.error.withValues(alpha: 0.14),
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
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.whatshot_rounded,
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
                    'Filler Word Challenge',
                    style: AppTypography.titleLarge(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'How long can you speak without "um"?',
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
                color: AppColors.accent,
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
}

class _WrappedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.push('/voice-wrapped'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Wrapped Ready!',
                    style: AppTypography.titleMedium(color: AppColors.white),
                  ),
                  Text(
                    'See your voice recap',
                    style: AppTypography.bodySmall(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
