import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_images.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/shared/widgets/mascot_widget.dart';
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
            Image.asset(
              AppImages.mascotEmpty,
              width: 160,
              height: 160,
              errorBuilder: (_, __, ___) => Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
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
    final avgScore = progress.sessionHistory.isNotEmpty
        ? (progress.sessionHistory
                .map((s) => s.overallScore)
                .reduce((a, b) => a + b) /
            progress.sessionHistory.length)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTypography.displayMedium(),
                    ),
                    Text(
                      'Last 7 days',
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak fire badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${progress.streak}',
                      style: AppTypography.titleMedium(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Speaker DNA Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Speaker DNA', style: AppTypography.titleMedium()),
                      Text(
                        'Unique Voice Print',
                        style: AppTypography.labelSmall(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Audio waveform visualization
                      Row(
                        children: List.generate(12, (i) {
                          final h = 8.0 + (sin(i * 0.8) + 1) * 10;
                          return Container(
                            width: 3,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.3 + (sin(i * 0.8) + 1) * 0.35,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // Speechy commentary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const MascotWidget(
                      state: MascotState.happy,
                      size: 40,
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          avgScore.toStringAsFixed(1),
                          style: AppTypography.labelSmall(
                            color: AppColors.white,
                          ).copyWith(fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speechy says:',
                        style: AppTypography.labelSmall(
                          color: context.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getSpeechyComment(avgScore, progress.streak),
                        style: AppTypography.bodySmall(
                          color: context.textSecondary,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Core Metrics
          Text('Core Metrics', style: AppTypography.headlineSmall())
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),
          const SizedBox(height: 12),

          _MetricRow(
            icon: Icons.shield_rounded,
            label: 'Confidence',
            description: _getMetricDescription('confidence', progress),
            valueText: _getMetricLevel('confidence', progress),
            valueColor: AppColors.success,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 8),
          _MetricRow(
            icon: Icons.waves_rounded,
            label: 'Clarity',
            description: _getMetricDescription('clarity', progress),
            valueText: _getMetricValue('clarity', progress),
            valueColor: AppColors.primary,
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
          const SizedBox(height: 8),
          _MetricRow(
            icon: Icons.favorite_rounded,
            label: 'Emotion',
            description: _getMetricDescription('emotion', progress),
            valueText: _getMetricLevel('emotion', progress),
            valueColor: AppColors.success,
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Score trend chart
          if (progress.sessionHistory.length >= 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
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
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
          if (progress.sessionHistory.length >= 2) const SizedBox(height: 16),

          // Badges
          if (progress.badges.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
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

  String _getSpeechyComment(double avgScore, int streak) {
    if (avgScore >= 85) {
      return '"You\'re crushing it! Your speaking skills are exceptional."';
    }
    if (avgScore >= 70) {
      return '"Great progress! Your consistency is really paying off."';
    }
    if (streak >= 3) {
      return '"Love the streak! Keep showing up and you\'ll see big improvements."';
    }
    return '"Every practice session makes you better. Keep going!"';
  }

  String _getMetricDescription(String metric, UserProgress progress) {
    final sessions = progress.sessionHistory;
    if (sessions.isEmpty) return 'No data yet';

    switch (metric) {
      case 'confidence':
        final avg = sessions.map((s) => s.confidence).reduce((a, b) => a + b) /
            sessions.length;
        return avg >= 75 ? 'Strong projection' : 'Building confidence';
      case 'clarity':
        final clarityAvg = sessions.map((s) => s.clarity).reduce((a, b) => a + b) /
            sessions.length;
        return clarityAvg >= 75 ? 'Clear communicator' : 'Building clarity';
      case 'emotion':
        final avg = sessions.map((s) => s.engagement).reduce((a, b) => a + b) /
            sessions.length;
        return avg >= 75 ? 'Warm & Engaging' : 'Building warmth';
      default:
        return '';
    }
  }

  String _getMetricLevel(String metric, UserProgress progress) {
    final sessions = progress.sessionHistory;
    if (sessions.isEmpty) return '--';

    double avg;
    switch (metric) {
      case 'confidence':
        avg = sessions.map((s) => s.confidence).reduce((a, b) => a + b) /
            sessions.length;
        break;
      case 'emotion':
        avg = sessions.map((s) => s.engagement).reduce((a, b) => a + b) /
            sessions.length;
        break;
      default:
        return '--';
    }
    if (avg >= 80) return 'High';
    if (avg >= 60) return 'Medium';
    return 'Building';
  }

  String _getMetricValue(String metric, UserProgress progress) {
    final sessions = progress.sessionHistory;
    if (sessions.isEmpty) return '--';

    switch (metric) {
      case 'clarity':
        final avg = sessions.map((s) => s.clarity).reduce((a, b) => a + b) /
            sessions.length;
        return '${avg.round()}%';
      default:
        return '--';
    }
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final String valueText;
  final Color valueColor;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.valueText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: valueColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleMedium()),
                Text(
                  description,
                  style: AppTypography.labelSmall(
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            valueText,
            style: AppTypography.titleMedium(color: valueColor)
                .copyWith(fontWeight: FontWeight.w800),
          ),
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
          const SkeletonLine(width: 180, height: 32),
          const SizedBox(height: 6),
          const SkeletonLine(width: 100, height: 14),
          const SizedBox(height: 24),
          Skeleton(height: 100, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 16),
          Skeleton(height: 80, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 24),
          const SkeletonLine(width: 140, height: 20),
          const SizedBox(height: 12),
          for (int i = 0; i < 3; i++) ...[
            Skeleton(height: 72, borderRadius: BorderRadius.circular(16)),
            const SizedBox(height: 8),
          ],
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
