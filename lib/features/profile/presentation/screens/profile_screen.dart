import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/core/extensions/string_extensions.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/auth/presentation/providers/auth_provider.dart';
import 'package:speech_coach/features/history/presentation/providers/session_history_provider.dart';
import 'package:speech_coach/features/history/domain/session_history_entity.dart';
import 'package:speech_coach/features/paywall/data/usage_service.dart';
import 'package:speech_coach/features/paywall/presentation/providers/subscription_provider.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/progress/presentation/widgets/xp_bar.dart';
import 'package:speech_coach/features/sharing/data/share_service.dart';
import 'package:speech_coach/features/speaker_dna/presentation/providers/speaker_dna_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionHistoryProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final progress = ref.watch(progressProvider);
    final sub = ref.watch(subscriptionProvider);
    final dnaState = ref.watch(speakerDNAProvider);
    final usageService = ref.watch(usageServiceProvider);
    final historyState = ref.watch(sessionHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    'Profile',
                    style: AppTypography.headlineLarge(),
                  ),
                  TextButton(
                    onPressed: () => context.push('/settings'),
                    child: Icon(
                      Icons.settings_outlined,
                      color: context.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar + Level
              authState.when(
                data: (user) {
                  final name = user?.displayName ?? 'User';
                  final email = user?.email ?? '';

                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.14),
                              child: Text(
                                name.initials,
                                style: AppTypography.displaySmall(
                                    color: AppColors.primary),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Lv.${progress.level}',
                              style: AppTypography.labelSmall(
                                  color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: AppTypography.headlineMedium()),
                      const SizedBox(height: 2),
                      Text(
                        progress.levelTitle,
                        style: AppTypography.bodySmall(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: AppTypography.bodySmall(
                          color: context.textSecondary,
                        ),
                      ),
                      if (dnaState.dna != null) ...[
                        const SizedBox(height: 8),
                        Tappable(
                          onTap: () => context.push('/speaker-dna-result'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dnaState.dna!.archetype,
                                  style: AppTypography.labelSmall(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(duration: 400.ms);
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading profile: $e'),
              ),
              const SizedBox(height: 24),

              // Stats grid
              Row(
                children: [
                  _StatCard(
                    icon: Icons.emoji_events_rounded,
                    value: '${progress.totalXp}',
                    label: 'Total XP',
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${progress.streak}',
                    label: 'Day Streak',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.mic_rounded,
                    value: '${progress.totalSessions}',
                    label: 'Sessions',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    icon: Icons.timer_rounded,
                    value: '${progress.totalMinutes}',
                    label: 'Minutes',
                    color: AppColors.skyBlue,
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 16),

              // XP Bar (moved from home)
              const XpBar()
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 400.ms),
              const SizedBox(height: 12),

              // Free tier indicator (moved from home)
              if (!usageService.isPro)
                Container(
                  width: double.infinity,
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
                        '${usageService.remainingSessions} free sessions today',
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
                    .fadeIn(delay: 130.ms, duration: 400.ms),
              const SizedBox(height: 12),

              // Streak Freeze (Pro feature)
              if (sub.isPro)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.ac_unit_rounded,
                          color: AppColors.skyBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak Freeze',
                              style: AppTypography.titleMedium(),
                            ),
                            Text(
                              '${progress.streakFreezes} remaining',
                              style: AppTypography.bodySmall(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 140.ms, duration: 400.ms),
              if (sub.isPro) const SizedBox(height: 12),

              // Recent Sessions (moved from home)
              if (historyState.status == SessionHistoryStatus.loaded &&
                  historyState.sessions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Sessions',
                          style: AppTypography.titleMedium(),
                        ),
                        Tappable(
                          onTap: () => context.push('/history'),
                          child: Text(
                            'See All',
                            style: AppTypography.labelMedium(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...historyState.sessions.take(3).map(
                          (session) => _RecentSessionTile(session: session),
                        ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 145.ms, duration: 400.ms),
              const SizedBox(height: 20),

              // Badges section
              if (progress.badges.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.gold,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Badges', style: AppTypography.titleMedium()),
                          const Spacer(),
                          Text(
                            '${progress.badges.length}',
                            style: AppTypography.labelMedium(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: progress.badges.map((badge) {
                          final label =
                              _badgeLabels[badge] ?? badge.replaceAll('_', ' ');
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.labelSmall(
                                  color: AppColors.gold),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 20),

              // Share streak
              if (progress.streak > 0)
                Tappable(
                  onTap: () => ShareService.shareStreakMilestone(
                    streak: progress.streak,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.22),
                          AppColors.primary.withValues(alpha: 0.22),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.share_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Share your ${progress.streak}-day streak!',
                            style: AppTypography.bodyMedium(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 20),

              // Menu items
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.fingerprint_rounded,
                      iconColor: AppColors.primary,
                      title: dnaState.dna != null
                          ? 'Retake Speaker DNA'
                          : 'Take Speaker DNA Quiz',
                      onTap: () => context.push('/speaker-dna-quiz'),
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileMenuItem(
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.skyBlue,
                      title: 'Analytics',
                      onTap: () => context.go('/progress'),
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileMenuItem(
                      icon: sub.isPro
                          ? Icons.workspace_premium_rounded
                          : Icons.workspace_premium_outlined,
                      iconColor: AppColors.gold,
                      title: sub.isPro ? 'Manage Subscription' : 'Upgrade to Pro',
                      onTap: () {
                        if (sub.isPro) {
                          ref.read(subscriptionProvider.notifier).showCustomerCenter();
                        } else {
                          context.push('/paywall');
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.secondary,
                      title: 'Help & Support',
                      onTap: () => launchUrl(
                        Uri.parse('mailto:support@speechyai.app'),
                      ),
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      iconColor: context.textSecondary,
                      title: 'Settings',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Log out
              Tappable(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('Sign Out'),
                      content:
                          const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signOut();
                  }
                },
                child: Text(
                  'Log out',
                  style: AppTypography.bodyLarge(color: AppColors.error),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static const _badgeLabels = <String, String>{
    'first_conversation': 'First Chat',
    '5_day_streak': '5-Day Streak',
    '10_day_streak': '10-Day Streak',
    'perfect_clarity': 'Perfect Clarity',
    'star_performer': 'Star Performer',
    'dedicated_10': '10 Sessions',
    'dedicated_50': '50 Sessions',
    'interviews_5': 'Interview Pro',
    'presentations_5': 'Presenter',
    'public_speaking_5': 'Public Speaker',
    'conversations_5': 'Conversationalist',
    'debates_5': 'Debater',
    'storytelling_5': 'Storyteller',
  };
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleLarge(color: color),
            ),
            Text(
              label,
              style: AppTypography.labelSmall(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge(),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.textTertiary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _RecentSessionTile extends StatelessWidget {
  final SessionHistoryEntry session;

  const _RecentSessionTile({required this.session});

  Color get _scoreColor {
    final score = session.overallScore ?? 0;
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final score = session.overallScore ?? 0;
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
                      value: score / 100,
                      strokeWidth: 3,
                      backgroundColor: context.divider,
                      color: _scoreColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$score',
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
