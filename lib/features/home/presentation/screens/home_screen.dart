import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/daily_goal/presentation/providers/daily_goal_provider.dart';
import 'package:speech_coach/shared/widgets/mascot_widget.dart';
import 'package:speech_coach/shared/widgets/progress_bar.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/auth/presentation/providers/auth_provider.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

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
  bool _wrappedShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowWrapped();
    });
  }

  void _maybeShowWrapped() {
    if (_wrappedShown) return;
    final progress = ref.read(progressProvider);
    if (_isWrappedAvailable(progress)) {
      _wrappedShown = true;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Monthly Wrapped Ready!',
                style: AppTypography.headlineSmall(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your voice recap for last month is ready.',
                style: AppTypography.bodySmall(
                  color: ctx.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/voice-wrapped');
              },
              child: const Text('View'),
            ),
          ],
        ),
      );
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final dailyGoal = ref.watch(dailyGoalProvider);
    final dailyChallenge = ref.watch(dailyChallengeProvider);
    final authState = ref.watch(authStateProvider);
    final userName = authState.whenData((user) => user?.displayName).value;
    final firstName = (userName != null && userName.isNotEmpty)
        ? userName.split(' ').first
        : 'Speaker';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // --- Section 1: Header ---
              Row(
                children: [
                  // User avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting.toUpperCase(),
                          style: AppTypography.labelSmall(
                            color: context.textTertiary,
                          ).copyWith(
                            letterSpacing: 1.0,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          firstName,
                          style: AppTypography.headlineSmall(),
                        ),
                      ],
                    ),
                  ),
                  // Settings
                  Tappable(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: context.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 24),

              // --- Section 2: Mascot + Speech bubble ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        const MascotWidget(
                          state: MascotState.happy,
                          size: 140,
                          showGlow: true,
                        ),
                        Positioned(
                          top: -8,
                          right: -40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Ready to speak?',
                              style: AppTypography.labelMedium(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Let's find your voice!",
                      style: AppTypography.headlineMedium(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consistency is key to fluency.',
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 24),

              // --- Section 3: Daily Goal Card ---
              _DailyGoalCard(
                completedToday: dailyGoal.completedToday,
                target: dailyGoal.targetSessions,
                dailyChallenge: dailyChallenge,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 24),

              // --- Section 4: Quick Start ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Start',
                    style: AppTypography.headlineSmall(),
                  ),
                  Tappable(
                    onTap: () => context.go('/practice'),
                    child: Text(
                      'View All',
                      style: AppTypography.labelMedium(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickStartCard(
                      title: 'Freestyle',
                      subtitle: 'Free practice',
                      icon: Icons.mic_rounded,
                      color: AppColors.cardPeach,
                      onTap: () => context.push(
                        '/conversation/${Uri.encodeComponent('Freestyle')}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStartCard(
                      title: 'Daily Lesson',
                      subtitle: 'Guided session',
                      icon: Icons.school_rounded,
                      color: AppColors.cardBlue,
                      onTap: () {
                        if (dailyChallenge != null) {
                          context.push(
                            '/scenario/${Uri.encodeComponent(dailyChallenge.id)}',
                          );
                        } else {
                          context.go('/practice');
                        }
                      },
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 24),

              // --- Section 5: Your Progress ---
              Text(
                'Your Progress',
                style: AppTypography.headlineSmall(),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: '${progress.streak}',
                        label: 'Streak',
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: context.divider,
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.chat_bubble_rounded,
                        value: '${progress.totalSessions}',
                        label: 'Sessions',
                        color: AppColors.skyBlue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: context.divider,
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.star_rounded,
                        value: progress.sessionHistory.isNotEmpty
                            ? '${(progress.sessionHistory.map((s) => s.overallScore).reduce((a, b) => a + b) / progress.sessionHistory.length).round()}%'
                            : '--',
                        label: 'Accuracy',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final int completedToday;
  final int target;
  final dynamic dailyChallenge;

  const _DailyGoalCard({
    required this.completedToday,
    required this.target,
    this.dailyChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (completedToday / target).clamp(0.0, 1.0);
    final isComplete = completedToday >= target;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.divider),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle_rounded : Icons.flag_rounded,
                color: isComplete ? AppColors.success : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Goal',
                style: AppTypography.titleMedium(),
              ),
              const Spacer(),
              const MascotWidget(
                state: MascotState.encouraging,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isComplete
                ? 'Great job! Goal completed!'
                : '${target - completedToday} session${target - completedToday > 1 ? "s" : ""} remaining',
            style: AppTypography.bodySmall(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: progress,
            height: 8,
            color: isComplete ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(height: 12),
          Tappable(
            onTap: () {
              if (dailyChallenge != null) {
                context.push(
                  '/scenario/${Uri.encodeComponent(dailyChallenge.id)}',
                );
              } else {
                context.push(
                  '/conversation/${Uri.encodeComponent('Freestyle')}',
                );
              }
            },
            child: Row(
              children: [
                Text(
                  isComplete ? 'Practice More' : 'Continue Practicing',
                  style: AppTypography.labelMedium(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickStartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTypography.titleMedium()),
            Text(
              subtitle,
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headlineMedium(color: color),
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
          Row(
            children: [
              const SkeletonCircle(size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(width: 100, height: 12),
                  const SizedBox(height: 6),
                  const SkeletonLine(width: 80, height: 20),
                ],
              ),
              const Spacer(),
              const SkeletonCircle(size: 40),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: SkeletonCircle(size: 140),
          ),
          const SizedBox(height: 16),
          Center(child: const SkeletonLine(width: 200, height: 24)),
          const SizedBox(height: 24),
          Skeleton(height: 140, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 24),
          const SkeletonLine(width: 120, height: 20),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Skeleton(
                  height: 100,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Skeleton(
                  height: 100,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
