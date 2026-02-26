import 'dart:math';

import 'package:speech_coach/features/scenarios/domain/scenario_entity.dart';

class DailyChallenge {
  DailyChallenge._();

  /// Returns a scenario deterministically based on today's date.
  /// Same scenario all day, changes the next day.
  static Scenario getToday(List<Scenario> scenarios) {
    if (scenarios.isEmpty) {
      throw StateError('No scenarios available');
    }
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    return scenarios[random.nextInt(scenarios.length)];
  }
}
