import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/feedback/domain/feedback_entity.dart';
import 'package:speech_coach/features/progress/data/progress_repository.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ProgressRepository(prefs);
});

class ProgressNotifier extends StateNotifier<UserProgress> {
  final ProgressRepository _repository;

  ProgressNotifier(this._repository) : super(const UserProgress()) {
    _load();
  }

  void _load() {
    state = _repository.load();
  }

  Future<void> addSession(ConversationFeedback feedback) async {
    final xp = feedback.xpEarned;
    final newTotalXp = state.totalXp + xp;
    final (newLevel, newLevelTitle) = UserProgress.calculateLevel(newTotalXp);

    // Calculate streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int newStreak = state.streak;

    if (state.lastSessionDate != null) {
      final lastDate = DateTime(
        state.lastSessionDate!.year,
        state.lastSessionDate!.month,
        state.lastSessionDate!.day,
      );
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak = state.streak + 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
      // diff == 0 means same day, keep streak
    } else {
      newStreak = 1;
    }

    final record = SessionRecord(
      scenarioId: feedback.scenarioId,
      category: feedback.category,
      overallScore: feedback.overallScore,
      clarity: feedback.clarity,
      confidence: feedback.confidence,
      engagement: feedback.engagement,
      relevance: feedback.relevance,
      durationSeconds: feedback.durationSeconds,
      xpEarned: xp,
      date: now,
    );

    // Check for new badges
    final newBadges = List<String>.from(state.badges);
    if (state.totalSessions == 0 && !newBadges.contains('first_conversation')) {
      newBadges.add('first_conversation');
    }
    if (newStreak >= 5 && !newBadges.contains('5_day_streak')) {
      newBadges.add('5_day_streak');
    }
    if (newStreak >= 10 && !newBadges.contains('10_day_streak')) {
      newBadges.add('10_day_streak');
    }
    if (feedback.clarity == 10 && !newBadges.contains('perfect_clarity')) {
      newBadges.add('perfect_clarity');
    }
    if (feedback.overallScore >= 90 && !newBadges.contains('star_performer')) {
      newBadges.add('star_performer');
    }
    if (state.totalSessions + 1 >= 10 && !newBadges.contains('dedicated_10')) {
      newBadges.add('dedicated_10');
    }
    if (state.totalSessions + 1 >= 50 && !newBadges.contains('dedicated_50')) {
      newBadges.add('dedicated_50');
    }

    // Check category-specific badges
    final categorySessions = state.sessionHistory
        .where((s) => s.category == feedback.category)
        .length + 1;
    final categoryBadge = '${feedback.category.toLowerCase().replaceAll(' ', '_')}_5';
    if (categorySessions >= 5 && !newBadges.contains(categoryBadge)) {
      newBadges.add(categoryBadge);
    }

    state = state.copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      levelTitle: newLevelTitle,
      streak: newStreak,
      longestStreak:
          newStreak > state.longestStreak ? newStreak : state.longestStreak,
      totalSessions: state.totalSessions + 1,
      totalMinutes:
          state.totalMinutes + (feedback.durationSeconds / 60).ceil(),
      lastSessionDate: now,
      badges: newBadges,
      sessionHistory: [...state.sessionHistory, record],
    );

    await _repository.save(state);
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, UserProgress>((ref) {
  final repository = ref.read(progressRepositoryProvider);
  return ProgressNotifier(repository);
});
