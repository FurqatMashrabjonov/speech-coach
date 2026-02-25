import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_coach/features/filler_challenge/domain/filler_challenge_entity.dart';

class FillerChallengeRepository {
  static const _historyKey = 'filler_challenge_history';
  static const _bestKey = 'filler_challenge_best';

  final SharedPreferences _prefs;

  FillerChallengeRepository(this._prefs);

  int get personalBest => _prefs.getInt(_bestKey) ?? 0;

  List<FillerChallengeResult> getHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) =>
              FillerChallengeResult.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveResult(FillerChallengeResult result) async {
    final history = getHistory();
    history.add(result);
    // Keep last 50
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }
    await _prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toMap()).toList()),
    );

    if (result.survivalSeconds > personalBest) {
      await _prefs.setInt(_bestKey, result.survivalSeconds);
    }
  }
}
