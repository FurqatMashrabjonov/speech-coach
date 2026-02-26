class DailyGoal {
  final int targetSessions;
  final int completedToday;
  final DateTime date;

  const DailyGoal({
    this.targetSessions = 1,
    this.completedToday = 0,
    required this.date,
  });

  bool get isComplete => completedToday >= targetSessions;

  double get progress =>
      targetSessions > 0 ? (completedToday / targetSessions).clamp(0.0, 1.0) : 0.0;
}
