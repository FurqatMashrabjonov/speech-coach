import 'package:home_widget/home_widget.dart';
import 'package:speech_coach/features/progress/domain/progress_entity.dart';

class WidgetService {
  static const _androidStatsWidget = 'StatsWidgetProvider';
  static const _androidPracticeWidget = 'PracticeWidgetProvider';

  static Future<void> updateWidgetData(UserProgress progress) async {
    await Future.wait([
      HomeWidget.saveWidgetData<int>('streak', progress.streak),
      HomeWidget.saveWidgetData<int>('level', progress.level),
      HomeWidget.saveWidgetData<String>('levelTitle', progress.levelTitle),
      HomeWidget.saveWidgetData<int>('totalXp', progress.totalXp),
      HomeWidget.saveWidgetData<int>('totalSessions', progress.totalSessions),
      HomeWidget.saveWidgetData<double>('xpProgress', progress.levelProgress),
      HomeWidget.saveWidgetData<int>('xpForNext', progress.xpForNextLevel),
    ]);

    await Future.wait([
      HomeWidget.updateWidget(androidName: _androidStatsWidget),
      HomeWidget.updateWidget(androidName: _androidPracticeWidget),
    ]);
  }
}
