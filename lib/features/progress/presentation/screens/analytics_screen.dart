import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: progress.sessionHistory.isEmpty
            ? _buildEmptyState(context)
            : _buildContent(context, progress),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Data Yet',
              style: AppTypography.headlineSmall(),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first practice session to see your analytics here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserProgress progress) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Progress', style: AppTypography.displayMedium())
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Sessions',
                  value: '${progress.totalSessions}',
                  icon: Icons.mic_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Minutes',
                  value: '${progress.totalMinutes}',
                  icon: Icons.timer_rounded,
                  color: AppColors.skyBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Streak',
                  value: '${progress.streak}',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Score trend chart
          if (progress.sessionHistory.length >= 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score Trend', style: AppTypography.titleMedium()),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _ScoreTrendChart(
                      sessions: progress.sessionHistory,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Category breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category Breakdown', style: AppTypography.titleMedium()),
                const SizedBox(height: 16),
                _CategoryBreakdown(sessions: progress.sessionHistory),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Skill radar
          if (progress.sessionHistory.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average Skills', style: AppTypography.titleMedium()),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: _SkillRadarChart(
                        sessions: progress.sessionHistory,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Badges
          if (progress.badges.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Badges', style: AppTypography.titleMedium()),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: progress.badges
                        .map((b) => _BadgeChip(badge: b))
                        .toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class AnalyticsSkeleton extends StatelessWidget {
  const AnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const SkeletonLine(width: 140, height: 32),
          const SizedBox(height: 24),
          // Stats row
          Row(
            children: [
              Expanded(
                child: Skeleton(
                  height: 90,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Skeleton(
                  height: 90,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Skeleton(
                  height: 90,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart card
          Skeleton(height: 260, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 16),
          // Category breakdown
          Skeleton(height: 180, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 16),
          // Skill radar
          Skeleton(height: 260, borderRadius: BorderRadius.circular(20)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
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
      ),
    );
  }
}

class _ScoreTrendChart extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _ScoreTrendChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final recentSessions = sessions.length > 20
        ? sessions.sublist(sessions.length - 20)
        : sessions;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: context.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 25,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: AppTypography.labelSmall(
                  color: context.textTertiary,
                ),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: recentSessions.asMap().entries.map((e) {
              return FlSpot(
                  e.key.toDouble(), e.value.overallScore.toDouble());
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _CategoryBreakdown({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final categoryMap = <String, List<SessionRecord>>{};
    for (final s in sessions) {
      categoryMap.putIfAbsent(s.category, () => []).add(s);
    }

    final categoryColors = {
      'Presentations': AppColors.categoryPresentations,
      'Interviews': AppColors.categoryInterviews,
      'Public Speaking': AppColors.categoryPublicSpeaking,
      'Conversations': AppColors.categoryConversations,
      'Debates': AppColors.categoryDebates,
      'Storytelling': AppColors.categoryStorytelling,
    };

    return Column(
      children: categoryMap.entries.map((entry) {
        final avgScore =
            entry.value.map((s) => s.overallScore).reduce((a, b) => a + b) /
                entry.value.length;
        final color = categoryColors[entry.key] ?? AppColors.primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.key,
                  style: AppTypography.bodySmall(),
                ),
              ),
              Text(
                '${entry.value.length} sessions',
                style: AppTypography.labelSmall(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Avg: ${avgScore.toStringAsFixed(0)}',
                style: AppTypography.labelMedium(color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SkillRadarChart extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _SkillRadarChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final avgClarity =
        sessions.map((s) => s.clarity).reduce((a, b) => a + b) /
            sessions.length;
    final avgConfidence =
        sessions.map((s) => s.confidence).reduce((a, b) => a + b) /
            sessions.length;
    final avgEngagement =
        sessions.map((s) => s.engagement).reduce((a, b) => a + b) /
            sessions.length;
    final avgRelevance =
        sessions.map((s) => s.relevance).reduce((a, b) => a + b) /
            sessions.length;

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: AppTypography.labelSmall(
          color: context.textTertiary,
        ),
        tickBorderData: BorderSide(
          color: context.divider,
          width: 1,
        ),
        gridBorderData: BorderSide(
          color: context.divider,
          width: 1,
        ),
        radarBorderData: const BorderSide(color: Colors.transparent),
        titleTextStyle: AppTypography.labelSmall(
          color: context.textSecondary,
        ),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return RadarChartTitle(text: 'Clarity');
            case 1:
              return RadarChartTitle(text: 'Confidence');
            case 2:
              return RadarChartTitle(text: 'Engagement');
            case 3:
              return RadarChartTitle(text: 'Relevance');
            default:
              return const RadarChartTitle(text: '');
          }
        },
        dataSets: [
          RadarDataSet(
            fillColor: AppColors.primary.withValues(alpha: 0.2),
            borderColor: AppColors.primary,
            borderWidth: 2,
            entryRadius: 4,
            dataEntries: [
              RadarEntry(value: avgClarity),
              RadarEntry(value: avgConfidence),
              RadarEntry(value: avgEngagement),
              RadarEntry(value: avgRelevance),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String badge;

  const _BadgeChip({required this.badge});

  static const _badgeInfo = {
    'first_conversation': ('First Chat', Icons.chat_bubble_rounded),
    '5_day_streak': ('5-Day Streak', Icons.local_fire_department_rounded),
    '10_day_streak': ('10-Day Streak', Icons.local_fire_department_rounded),
    'perfect_clarity': ('Perfect Clarity', Icons.visibility_rounded),
    'star_performer': ('Star Performer', Icons.star_rounded),
    'dedicated_10': ('10 Sessions', Icons.emoji_events_rounded),
    'dedicated_50': ('50 Sessions', Icons.workspace_premium_rounded),
    'interviews_5': ('Interview Pro', Icons.work_rounded),
    'presentations_5': ('Presenter', Icons.slideshow_rounded),
    'public_speaking_5': ('Public Speaker', Icons.campaign_rounded),
    'conversations_5': ('Conversationalist', Icons.chat_rounded),
    'debates_5': ('Debater', Icons.forum_rounded),
    'storytelling_5': ('Storyteller', Icons.auto_stories_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final info = _badgeInfo[badge];
    final label = info?.$1 ?? badge.replaceAll('_', ' ');
    final icon = info?.$2 ?? Icons.emoji_events_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall(color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}
