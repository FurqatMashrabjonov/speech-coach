import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';

class UsageService {
  static const _keySessionCount = 'daily_session_count';
  static const _keyLastSessionDate = 'last_session_date';
  static const _keyIsPro = 'is_pro_user';
  static const int freeSessionsPerDay = 3;

  final SharedPreferences _prefs;

  UsageService(this._prefs);

  bool get isPro => _prefs.getBool(_keyIsPro) ?? false;

  int get todaySessionCount {
    final lastDate = _prefs.getString(_keyLastSessionDate);
    final today = _todayString();
    if (lastDate != today) return 0;
    return _prefs.getInt(_keySessionCount) ?? 0;
  }

  int get remainingSessions {
    if (isPro) return 999;
    return (freeSessionsPerDay - todaySessionCount).clamp(0, freeSessionsPerDay);
  }

  bool canStartSession() {
    if (isPro) return true;
    return todaySessionCount < freeSessionsPerDay;
  }

  void recordSession() {
    final today = _todayString();
    final lastDate = _prefs.getString(_keyLastSessionDate);

    if (lastDate != today) {
      _prefs.setString(_keyLastSessionDate, today);
      _prefs.setInt(_keySessionCount, 1);
    } else {
      final count = _prefs.getInt(_keySessionCount) ?? 0;
      _prefs.setInt(_keySessionCount, count + 1);
    }
  }

  Future<void> setPro(bool value) async {
    await _prefs.setBool(_keyIsPro, value);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final usageServiceProvider = Provider<UsageService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UsageService(prefs);
});
