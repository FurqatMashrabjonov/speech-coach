import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/daily_goal/domain/daily_challenge.dart';
import 'package:speech_coach/features/daily_goal/domain/daily_goal_entity.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/scenarios/domain/scenario_entity.dart';
import 'package:speech_coach/features/scenarios/presentation/providers/scenario_provider.dart';

final dailyGoalProvider = Provider<DailyGoal>((ref) {
  final progress = ref.watch(progressProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final completedToday = progress.sessionHistory
      .where((s) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        return d == today;
      })
      .length;

  return DailyGoal(
    targetSessions: 1,
    completedToday: completedToday,
    date: today,
  );
});

final dailyChallengeProvider = Provider<Scenario?>((ref) {
  final scenarios = ref.watch(allScenariosProvider);
  if (scenarios.isEmpty) return null;
  return DailyChallenge.getToday(scenarios);
});

/// Returns the category with fewest completed sessions to encourage exploration.
final suggestedCategoryProvider = Provider<String?>((ref) {
  final progress = ref.watch(progressProvider);
  final scenarios = ref.watch(allScenariosProvider);

  if (scenarios.isEmpty) return null;

  // Get all unique categories
  final categories = scenarios.map((s) => s.category).toSet();

  // Count sessions per category
  final counts = <String, int>{};
  for (final cat in categories) {
    counts[cat] = progress.sessionHistory.where((s) => s.category == cat).length;
  }

  // Return category with fewest sessions
  String? minCategory;
  int minCount = 999999;
  for (final entry in counts.entries) {
    if (entry.value < minCount) {
      minCount = entry.value;
      minCategory = entry.key;
    }
  }
  return minCategory;
});
