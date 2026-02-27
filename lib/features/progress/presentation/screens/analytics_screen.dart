import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/progress/presentation/utils/metric_helpers.dart';
import 'package:speech_coach/features/progress/presentation/widgets/metric_row.dart';
import 'package:speech_coach/features/progress/presentation/widgets/score_trend_chart.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realProgress = ref.watch(progressProvider);

    // Use real data if available, otherwise show demo data
    final progress = realProgress.sessionHistory.isNotEmpty
        ? realProgress
        : _demoProgress;
    final isDemo = realProgress.sessionHistory.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: _buildContent(context, progress, isDemo: isDemo),
      ),
    );
  }

  static final _demoProgress = UserProgress(
    totalXp: 2450,
    level: 5,
    levelTitle: 'Skilled',
    streak: 12,
    longestStreak: 18,
    totalSessions: 47,
    totalMinutes: 186,
    lastSessionDate: DateTime.now().subtract(const Duration(hours: 3)),
    badges: [
      'first_conversation',
      '5_day_streak',
      '10_day_streak',
      'dedicated_10',
      'interviews_5',
      'star_performer',
    ],
    sessionHistory: _generateDemoSessions(),
  );

  static List<SessionRecord> _generateDemoSessions() {
    final rng = Random(42);
    final now = DateTime.now();
    final categories = [
      'Interviews',
      'Presentations',
      'Public Speaking',
      'Conversations',
      'Debates',
      'Storytelling',
      'Phone Anxiety',
      'Dating & Social',
    ];

    final sessions = <SessionRecord>[];
    for (int i = 0; i < 47; i++) {
      final daysAgo = (i * 1.9).toInt() + rng.nextInt(2);
      final cat = categories[rng.nextInt(categories.length)];
      final base = 55 + rng.nextInt(35);
      sessions.add(SessionRecord(
        scenarioId: 'demo_$i',
        category: cat,
        overallScore: base,
        clarity: (base - 5 + rng.nextInt(15)).clamp(20, 100),
        confidence: (base - 8 + rng.nextInt(18)).clamp(20, 100),
        engagement: (base - 3 + rng.nextInt(12)).clamp(20, 100),
        relevance: (base + rng.nextInt(10)).clamp(20, 100),
        durationSeconds: 120 + rng.nextInt(300),
        xpEarned: 30 + rng.nextInt(70),
        date: now.subtract(Duration(days: daysAgo, hours: rng.nextInt(12))),
      ));
    }
    return sessions;
  }

  Widget _buildContent(BuildContext context, UserProgress progress,
      {bool isDemo = false}) {
    final sessions = progress.sessionHistory;
    final avgScore = sessions.isNotEmpty
        ? sessions.map((s) => s.overallScore).reduce((a, b) => a + b) /
            sessions.length
        : 0.0;
    final bestScore = sessions.isNotEmpty
        ? sessions.map((s) => s.overallScore).reduce(max)
        : 0;
    final totalMinutes = progress.totalMinutes;

    // Category breakdown
    final categoryMap = <String, int>{};
    for (final s in sessions) {
      categoryMap[s.category] = (categoryMap[s.category] ?? 0) + 1;
    }
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Weekly sessions (last 7 days)
    final now = DateTime.now();
    final weekSessions = List<int>.filled(7, 0);
    for (final s in sessions) {
      final diff = now.difference(s.date).inDays;
      if (diff >= 0 && diff < 7) {
        weekSessions[6 - diff]++;
      }
    }

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
                child: Text('Results', style: AppTypography.headlineLarge()),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      style:
                          AppTypography.titleMedium(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          // Demo banner
          if (isDemo) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sample data — complete sessions to see your real stats',
                      style: AppTypography.labelSmall(
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // ============ OVERVIEW STATS ============
          Row(
            children: [
              _BigStatCard(
                value: '${progress.totalSessions}',
                label: 'Sessions',
                icon: Icons.mic_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _BigStatCard(
                value: avgScore.toStringAsFixed(0),
                label: 'Avg Score',
                icon: Icons.speed_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 10),
              _BigStatCard(
                value: '$bestScore',
                label: 'Best',
                icon: Icons.emoji_events_rounded,
                color: AppColors.gold,
              ),
              const SizedBox(width: 10),
              _BigStatCard(
                value: '${totalMinutes}m',
                label: 'Practice',
                icon: Icons.timer_rounded,
                color: AppColors.skyBlue,
              ),
            ],
          ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
          const SizedBox(height: 20),

          // ============ ACTIVITY HEATMAP ============
          _ActivityHeatmap(sessions: sessions)
              .animate()
              .fadeIn(delay: 160.ms, duration: 400.ms),
          const SizedBox(height: 20),

          // ============ WEEKLY BAR CHART ============
          _SectionCard(
            title: 'This Week',
            child: SizedBox(
              height: 160,
              child: _WeeklyBarChart(weekSessions: weekSessions),
            ),
          ).animate().fadeIn(delay: 240.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // ============ CATEGORY BREAKDOWN ============
          if (sortedCategories.isNotEmpty)
            _SectionCard(
              title: 'Categories',
              child: Column(
                children: sortedCategories.take(5).map((entry) {
                  final pct = entry.value / sessions.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CategoryBar(
                      category: entry.key,
                      count: entry.value,
                      percentage: pct,
                      color: _categoryColor(entry.key),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
          if (sortedCategories.isNotEmpty) const SizedBox(height: 16),

          // ============ SCORE TREND ============
          if (sessions.length >= 2)
            _SectionCard(
              title: 'Score Trend',
              child: SizedBox(
                height: 200,
                child: ScoreTrendChart(sessions: sessions),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          if (sessions.length >= 2) const SizedBox(height: 16),

          // ============ CORE METRICS ============
          Text('Core Metrics', style: AppTypography.headlineSmall())
              .animate()
              .fadeIn(delay: 480.ms, duration: 400.ms),
          const SizedBox(height: 12),
          MetricRow(
            icon: Icons.shield_rounded,
            label: 'Confidence',
            description: getMetricDescription('confidence', progress),
            valueText: getMetricLevel('confidence', progress),
            valueColor: AppColors.success,
          ).animate().fadeIn(delay: 520.ms, duration: 400.ms),
          const SizedBox(height: 8),
          MetricRow(
            icon: Icons.waves_rounded,
            label: 'Clarity',
            description: getMetricDescription('clarity', progress),
            valueText: getMetricValue('clarity', progress),
            valueColor: AppColors.primary,
          ).animate().fadeIn(delay: 560.ms, duration: 400.ms),
          const SizedBox(height: 8),
          MetricRow(
            icon: Icons.favorite_rounded,
            label: 'Emotion',
            description: getMetricDescription('emotion', progress),
            valueText: getMetricLevel('emotion', progress),
            valueColor: AppColors.success,
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          const SizedBox(height: 20),

          // ============ SCORE DISTRIBUTION ============
          _SectionCard(
            title: 'Score Distribution',
            child: SizedBox(
              height: 140,
              child: _ScoreDistribution(sessions: sessions),
            ),
          ).animate().fadeIn(delay: 640.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // ============ BADGES ============
          if (progress.badges.isNotEmpty)
            _SectionCard(
              title: 'Badges (${progress.badges.length})',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: progress.badges
                    .map((b) => _BadgeChip(badge: b))
                    .toList(),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'interviews':
        return AppColors.primary;
      case 'presentations':
        return AppColors.secondary;
      case 'public speaking':
        return const Color(0xFFCE82FF);
      case 'conversations':
        return AppColors.success;
      case 'debates':
        return AppColors.error;
      case 'storytelling':
        return AppColors.gold;
      case 'phone anxiety':
        return AppColors.skyBlue;
      case 'dating & social':
        return const Color(0xFFFF6B9D);
      case 'conflict & boundaries':
        return const Color(0xFFFF8C42);
      case 'social situations':
        return const Color(0xFF4ECDC4);
      default:
        return AppColors.primary;
    }
  }
}

// ─── Overview Stat Card ─────────────────────────────────────────────────────

class _BigStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleLarge(color: color)
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              label,
              style: AppTypography.labelSmall(color: context.textSecondary)
                  .copyWith(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Heatmap (GitHub-style, 30 days, primary color) ────────────────

class _ActivityHeatmap extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _ActivityHeatmap({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build a map of date → session count for last 35 days (5 weeks)
    final activityMap = <DateTime, int>{};
    for (final s in sessions) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      final diff = today.difference(d).inDays;
      if (diff >= 0 && diff < 35) {
        activityMap[d] = (activityMap[d] ?? 0) + 1;
      }
    }

    // 5 weeks × 7 days grid, aligned to start on Monday
    final daysBack = 34 + (today.weekday - 1); // align to Monday
    final startDate = today.subtract(Duration(days: daysBack));
    final weeks = <List<_HeatmapDay>>[];
    var current = startDate;
    var week = <_HeatmapDay>[];

    while (!current.isAfter(today)) {
      final count = activityMap[current] ?? 0;
      final isFuture = current.isAfter(today);
      week.add(_HeatmapDay(date: current, count: count, isFuture: isFuture));
      if (week.length == 7) {
        weeks.add(week);
        week = [];
      }
      current = current.add(const Duration(days: 1));
    }
    if (week.isNotEmpty) {
      // Pad remaining days as future
      while (week.length < 7) {
        week.add(_HeatmapDay(
          date: current,
          count: 0,
          isFuture: true,
        ));
        current = current.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    // Count active days this month
    final activeDays = activityMap.keys
        .where((d) => today.difference(d).inDays < 30)
        .length;

    const dayLabels = ['Mon', '', 'Wed', '', 'Fri', '', 'Sun'];

    // Month name for header
    final monthName = _monthName(today.month);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity', style: AppTypography.titleLarge()),
                  const SizedBox(height: 2),
                  Text(
                    '$monthName ${today.year}',
                    style: AppTypography.bodySmall(
                        color: context.textSecondary),
                  ),
                ],
              ),
              // Active days badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$activeDays active days',
                      style: AppTypography.labelMedium(
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Heatmap grid
          LayoutBuilder(builder: (context, constraints) {
            final labelWidth = 32.0;
            final gridWidth = constraints.maxWidth - labelWidth - 4;
            final cellGap = 3.0;
            final numWeeks = weeks.length;
            final cellSize =
                (gridWidth - (numWeeks - 1) * cellGap) / numWeeks;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day labels
                SizedBox(
                  width: labelWidth,
                  child: Column(
                    children: dayLabels.map((label) {
                      return SizedBox(
                        height: cellSize + cellGap,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            style: AppTypography.labelSmall(
                                    color: context.textTertiary)
                                .copyWith(fontSize: 10),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 4),
                // Grid
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weeks.map((weekDays) {
                      return Column(
                        children: weekDays.map((day) {
                          return Container(
                            width: cellSize,
                            height: cellSize,
                            margin: EdgeInsets.only(bottom: cellGap),
                            decoration: BoxDecoration(
                              color: day.isFuture
                                  ? Colors.transparent
                                  : _heatColor(day.count),
                              borderRadius: BorderRadius.circular(4),
                              border: day.isFuture
                                  ? Border.all(
                                      color: const Color(0xFFE5E5E5),
                                      width: 1,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sessions.length} total sessions',
                style: AppTypography.labelSmall(
                    color: context.textSecondary),
              ),
              Row(
                children: [
                  Text('Less',
                      style: AppTypography.labelSmall(
                              color: context.textTertiary)
                          .copyWith(fontSize: 10)),
                  const SizedBox(width: 4),
                  for (final level in [0, 1, 2, 3])
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _heatColor(level),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Text('More',
                      style: AppTypography.labelSmall(
                              color: context.textTertiary)
                          .copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _heatColor(int count) {
    if (count == 0) return const Color(0xFFEBEDF0);
    if (count == 1) return AppColors.primary.withValues(alpha: 0.25);
    if (count == 2) return AppColors.primary.withValues(alpha: 0.55);
    return AppColors.primary;
  }

  static String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month];
  }
}

class _HeatmapDay {
  final DateTime date;
  final int count;
  final bool isFuture;

  const _HeatmapDay({
    required this.date,
    required this.count,
    this.isFuture = false,
  });
}

// ─── Weekly Bar Chart ───────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final List<int> weekSessions;

  const _WeeklyBarChart({required this.weekSessions});

  @override
  Widget build(BuildContext context) {
    final maxVal = weekSessions.reduce(max).toDouble();
    final dayLabels = _last7DayLabels();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal > 0 ? maxVal + 1 : 4,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} sessions',
                AppTypography.labelSmall(color: AppColors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < dayLabels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayLabels[idx],
                      style: AppTypography.labelSmall(
                              color: context.textTertiary)
                          .copyWith(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: weekSessions[i].toDouble(),
                color: weekSessions[i] > 0
                    ? AppColors.primary
                    : const Color(0xFFE5E5E5),
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<String> _last7DayLabels() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });
  }
}

// ─── Category Breakdown Bar ─────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final String category;
  final int count;
  final double percentage;
  final Color color;

  const _CategoryBar({
    required this.category,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: AppTypography.labelMedium(),
            ),
            Text(
              '$count sessions',
              style:
                  AppTypography.labelSmall(color: context.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFE5E5E5),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─── Score Distribution ─────────────────────────────────────────────────────

class _ScoreDistribution extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _ScoreDistribution({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Bucket scores: 0-20, 20-40, 40-60, 60-80, 80-100
    final buckets = List<int>.filled(5, 0);
    for (final s in sessions) {
      final idx = (s.overallScore / 20).floor().clamp(0, 4);
      buckets[idx]++;
    }
    final maxBucket = buckets.reduce(max).toDouble();
    final labels = ['0-20', '21-40', '41-60', '61-80', '81-100'];
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.gold,
      AppColors.primary,
      AppColors.success,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxBucket > 0 ? maxBucket + 1 : 4,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} sessions',
                AppTypography.labelSmall(color: AppColors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[idx],
                      style: AppTypography.labelSmall(
                              color: context.textTertiary)
                          .copyWith(fontSize: 9),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(5, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: buckets[i].toDouble(),
                color: colors[i],
                width: 32,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium()),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Badge Chip ─────────────────────────────────────────────────────────────

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

// ─── Skeleton ───────────────────────────────────────────────────────────────

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
