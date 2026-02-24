import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int streak;
  final int totalSessions;
  final String? lastCategory;
  final List<DailyChallenge> dailyChallenges;

  const HomeState({
    this.streak = 0,
    this.totalSessions = 0,
    this.lastCategory,
    this.dailyChallenges = const [],
  });
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationMinutes;
  final bool isCompleted;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.durationMinutes = 5,
    this.isCompleted = false,
  });
}

final homeProvider = StateProvider<HomeState>((ref) {
  return HomeState(
    streak: 3,
    totalSessions: 12,
    lastCategory: 'Presentations',
    dailyChallenges: const [
      DailyChallenge(
        id: '1',
        title: 'Elevator Pitch',
        description: 'Introduce yourself in 60 seconds',
        category: 'Presentations',
        durationMinutes: 2,
      ),
      DailyChallenge(
        id: '2',
        title: 'Tell a Story',
        description: 'Share a personal anecdote with emotion',
        category: 'Storytelling',
        durationMinutes: 3,
      ),
      DailyChallenge(
        id: '3',
        title: 'Debate Practice',
        description: 'Argue for or against a random topic',
        category: 'Debates',
        durationMinutes: 5,
      ),
    ],
  );
});
