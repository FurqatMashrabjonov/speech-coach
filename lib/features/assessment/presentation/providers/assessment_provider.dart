import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:speech_coach/shared/providers/user_provider.dart';
import '../../data/assessment_data.dart';
import '../../data/assessment_repository.dart';
import '../../domain/assessment_entity.dart';
import '../../domain/learning_plan_entity.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AssessmentRepository(prefs);
});

final hasAssessmentProvider = Provider<bool>((ref) {
  final repo = ref.read(assessmentRepositoryProvider);
  return repo.hasCompletedAssessment();
});

final learningPlanProvider =
    StateNotifierProvider<LearningPlanNotifier, LearningPlan?>((ref) {
  final repo = ref.read(assessmentRepositoryProvider);
  return LearningPlanNotifier(repo);
});

class LearningPlanNotifier extends StateNotifier<LearningPlan?> {
  final AssessmentRepository _repo;

  LearningPlanNotifier(this._repo) : super(null) {
    _load();
  }

  void _load() {
    state = _repo.getLearningPlan();
  }

  Future<void> generateFromAssessment(List<AssessmentAnswer> answers) async {
    final templateId = matchTemplate(answers);
    final result = AssessmentResult(
      answers: answers,
      templateId: templateId,
      completedAt: DateTime.now(),
    );

    await _repo.saveAssessmentResult(result);

    final plan = generatePlan(result);
    await _repo.saveLearningPlan(plan);
    state = plan;
  }

  Future<void> markCompleted(String scenarioId, double score) async {
    if (state == null) return;
    await _repo.markStepCompleted(scenarioId, score);
    state = _repo.getLearningPlan();
  }

  PlanStep? get nextStep => state?.nextStep;
}
