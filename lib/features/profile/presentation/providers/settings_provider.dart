import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';

final defaultVoiceProvider = StateProvider<String>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getString('default_voice') ?? 'Puck';
});

final defaultDurationProvider = StateProvider<int>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getInt('default_duration_minutes') ?? 3;
});

final autoScoreProvider = StateProvider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool('auto_score') ?? true;
});

final practiceRemindersProvider = StateProvider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool('practice_reminders') ?? true;
});

final reminderTimeHourProvider = StateProvider<int>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getInt('reminder_time_hour') ?? 19;
});

final reminderTimeMinuteProvider = StateProvider<int>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getInt('reminder_time_minute') ?? 0;
});

final streakRemindersProvider = StateProvider<bool>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return prefs.getBool('streak_reminders') ?? true;
});
