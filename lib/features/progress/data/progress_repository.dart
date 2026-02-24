import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';

class ProgressRepository {
  static const _key = 'user_progress';
  final SharedPreferences _prefs;

  ProgressRepository(this._prefs);

  UserProgress load() {
    final json = _prefs.getString(_key);
    if (json == null) return const UserProgress();
    try {
      return UserProgress.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    await _prefs.setString(_key, jsonEncode(progress.toMap()));
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
