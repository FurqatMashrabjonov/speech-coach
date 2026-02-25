class VoiceWrapped {
  final int month;
  final int year;
  final int totalMinutes;
  final int sessionsCompleted;
  final double scoreImprovement;
  final String bestCategory;
  final String monthArchetype;
  final int averageScore;
  final Map<String, int> categoryCounts;

  const VoiceWrapped({
    required this.month,
    required this.year,
    required this.totalMinutes,
    required this.sessionsCompleted,
    required this.scoreImprovement,
    required this.bestCategory,
    required this.monthArchetype,
    required this.averageScore,
    required this.categoryCounts,
  });

  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }
}
