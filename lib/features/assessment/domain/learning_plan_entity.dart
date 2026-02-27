class LearningPlan {
  final String templateId;
  final String title;
  final String description;
  final List<PlanStep> steps;
  final DateTime createdAt;

  const LearningPlan({
    required this.templateId,
    required this.title,
    required this.description,
    required this.steps,
    required this.createdAt,
  });

  int get completedCount => steps.where((s) => s.isCompleted).length;
  int get totalSteps => steps.length;
  double get progressPercent =>
      totalSteps == 0 ? 0 : completedCount / totalSteps;

  PlanStep? get nextStep {
    try {
      return steps.firstWhere((s) => !s.isCompleted);
    } catch (_) {
      return null;
    }
  }

  LearningPlan copyWith({List<PlanStep>? steps}) => LearningPlan(
        templateId: templateId,
        title: title,
        description: description,
        steps: steps ?? this.steps,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'templateId': templateId,
        'title': title,
        'description': description,
        'steps': steps.map((s) => s.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory LearningPlan.fromMap(Map<String, dynamic> map) => LearningPlan(
        templateId: map['templateId'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        steps: (map['steps'] as List)
            .map((s) => PlanStep.fromMap(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class PlanStep {
  final String scenarioId;
  final int order;
  final bool isCompleted;
  final double? score;

  const PlanStep({
    required this.scenarioId,
    required this.order,
    this.isCompleted = false,
    this.score,
  });

  PlanStep markCompleted(double score) => PlanStep(
        scenarioId: scenarioId,
        order: order,
        isCompleted: true,
        score: score,
      );

  Map<String, dynamic> toMap() => {
        'scenarioId': scenarioId,
        'order': order,
        'isCompleted': isCompleted,
        'score': score,
      };

  factory PlanStep.fromMap(Map<String, dynamic> map) => PlanStep(
        scenarioId: map['scenarioId'] as String,
        order: map['order'] as int,
        isCompleted: map['isCompleted'] as bool? ?? false,
        score: (map['score'] as num?)?.toDouble(),
      );
}
