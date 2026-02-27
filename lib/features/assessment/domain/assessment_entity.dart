class AssessmentAnswer {
  final String questionId;
  final String optionId;

  const AssessmentAnswer({
    required this.questionId,
    required this.optionId,
  });

  Map<String, dynamic> toMap() => {
        'questionId': questionId,
        'optionId': optionId,
      };

  factory AssessmentAnswer.fromMap(Map<String, dynamic> map) =>
      AssessmentAnswer(
        questionId: map['questionId'] as String,
        optionId: map['optionId'] as String,
      );
}

class AssessmentResult {
  final List<AssessmentAnswer> answers;
  final String templateId;
  final DateTime completedAt;

  const AssessmentResult({
    required this.answers,
    required this.templateId,
    required this.completedAt,
  });

  String answerFor(String questionId) {
    return answers
        .firstWhere(
          (a) => a.questionId == questionId,
          orElse: () => const AssessmentAnswer(questionId: '', optionId: ''),
        )
        .optionId;
  }

  Map<String, dynamic> toMap() => {
        'answers': answers.map((a) => a.toMap()).toList(),
        'templateId': templateId,
        'completedAt': completedAt.toIso8601String(),
      };

  factory AssessmentResult.fromMap(Map<String, dynamic> map) =>
      AssessmentResult(
        answers: (map['answers'] as List)
            .map((a) => AssessmentAnswer.fromMap(a as Map<String, dynamic>))
            .toList(),
        templateId: map['templateId'] as String,
        completedAt: DateTime.parse(map['completedAt'] as String),
      );
}
