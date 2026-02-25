import 'package:speech_coach/features/progress/domain/progress_entity.dart';
import 'package:speech_coach/features/voice_wrapped/domain/voice_wrapped_entity.dart';

class VoiceWrappedService {
  static VoiceWrapped? compute(UserProgress progress, int month, int year) {
    final sessions = progress.sessionHistory
        .where((s) => s.date.month == month && s.date.year == year)
        .toList();

    if (sessions.isEmpty) return null;

    // Total minutes
    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + (s.durationSeconds ~/ 60));

    // Average score
    final avgScore = sessions.isEmpty
        ? 0
        : sessions.fold<int>(0, (sum, s) => sum + s.overallScore) ~/
            sessions.length;

    // Category counts
    final categoryCounts = <String, int>{};
    for (final s in sessions) {
      categoryCounts[s.category] = (categoryCounts[s.category] ?? 0) + 1;
    }

    // Best category
    String bestCategory = '';
    int maxCount = 0;
    for (final entry in categoryCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        bestCategory = entry.key;
      }
    }

    // Score improvement vs previous month
    final prevMonth = month > 1 ? month - 1 : 12;
    final prevYear = month > 1 ? year : year - 1;
    final prevSessions = progress.sessionHistory
        .where((s) => s.date.month == prevMonth && s.date.year == prevYear)
        .toList();
    double improvement = 0;
    if (prevSessions.isNotEmpty) {
      final prevAvg = prevSessions.fold<int>(0, (sum, s) => sum + s.overallScore) ~/
          prevSessions.length;
      if (prevAvg > 0) {
        improvement = ((avgScore - prevAvg) / prevAvg) * 100;
      }
    }

    // Archetype
    final archetype = _computeArchetype(sessions.length, improvement);

    return VoiceWrapped(
      month: month,
      year: year,
      totalMinutes: totalMinutes,
      sessionsCompleted: sessions.length,
      scoreImprovement: improvement,
      bestCategory: bestCategory,
      monthArchetype: archetype,
      averageScore: avgScore,
      categoryCounts: categoryCounts,
    );
  }

  static String _computeArchetype(int sessionCount, double improvement) {
    if (sessionCount >= 20 && improvement > 10) return 'The Machine';
    if (sessionCount >= 20) return 'The Grinder';
    if (improvement > 15) return 'The Rocket';
    if (improvement > 5) return 'The Consistent Improver';
    if (sessionCount >= 10) return 'The Dedicated Speaker';
    if (sessionCount >= 5) return 'The Explorer';
    return 'The Starter';
  }
}
