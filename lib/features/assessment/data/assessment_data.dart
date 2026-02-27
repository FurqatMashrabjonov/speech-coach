import '../domain/assessment_entity.dart';
import '../domain/learning_plan_entity.dart';

// --- Assessment Questions ---

class AssessmentOption {
  final String id;
  final String label;
  final String emoji;

  const AssessmentOption({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

class AssessmentQuestion {
  final String id;
  final String text;
  final List<AssessmentOption> options;

  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}

const assessmentQuestions = [
  AssessmentQuestion(
    id: 'goal',
    text: "What's your main speaking goal?",
    options: [
      AssessmentOption(
          id: 'career', label: 'Ace job interviews', emoji: '\u{1F4BC}'),
      AssessmentOption(
          id: 'social', label: 'Feel confident socially', emoji: '\u{1F91D}'),
      AssessmentOption(
          id: 'public', label: 'Master public speaking', emoji: '\u{1F3A4}'),
      AssessmentOption(
          id: 'dating',
          label: 'Navigate dating conversations',
          emoji: '\u{1F496}'),
    ],
  ),
  AssessmentQuestion(
    id: 'level',
    text: 'How would you rate your current speaking skills?',
    options: [
      AssessmentOption(
          id: 'beginner', label: 'Just starting out', emoji: '\u{1F331}'),
      AssessmentOption(
          id: 'intermediate',
          label: 'Decent but want to improve',
          emoji: '\u{1F4AA}'),
      AssessmentOption(
          id: 'advanced',
          label: 'Good but want to be great',
          emoji: '\u{2B50}'),
    ],
  ),
  AssessmentQuestion(
    id: 'challenge',
    text: "What's your biggest speaking challenge?",
    options: [
      AssessmentOption(
          id: 'confidence', label: 'Lack of confidence', emoji: '\u{1F614}'),
      AssessmentOption(
          id: 'filler', label: 'Too many filler words', emoji: '\u{1F4AC}'),
      AssessmentOption(
          id: 'structure', label: 'Organizing my thoughts', emoji: '\u{1F9E9}'),
      AssessmentOption(
          id: 'anxiety', label: 'Speaking anxiety', emoji: '\u{1F630}'),
    ],
  ),
  AssessmentQuestion(
    id: 'context',
    text: 'Where do you speak most?',
    options: [
      AssessmentOption(
          id: 'work', label: 'Work / professional', emoji: '\u{1F3E2}'),
      AssessmentOption(
          id: 'social', label: 'Social gatherings', emoji: '\u{1F389}'),
      AssessmentOption(
          id: 'school', label: 'School / university', emoji: '\u{1F393}'),
      AssessmentOption(
          id: 'phone', label: 'Phone calls', emoji: '\u{1F4F1}'),
    ],
  ),
  AssessmentQuestion(
    id: 'time',
    text: 'How much time can you practice daily?',
    options: [
      AssessmentOption(id: '5min', label: '5 minutes', emoji: '\u{23F1}'),
      AssessmentOption(id: '10min', label: '10 minutes', emoji: '\u{23F0}'),
      AssessmentOption(id: '15min', label: '15+ minutes', emoji: '\u{1F525}'),
    ],
  ),
];

// --- Plan Templates ---

class _PlanTemplate {
  final String id;
  final String title;
  final String description;
  final List<String> scenarioIds;

  const _PlanTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.scenarioIds,
  });
}

const _templates = [
  _PlanTemplate(
    id: 'career_confidence',
    title: 'Career Confidence Builder',
    description:
        'Master interviews and professional speaking, from elevator pitches to salary negotiations.',
    scenarioIds: [
      'int_1', // Tell Me About Yourself (Easy)
      'pres_1', // Elevator Pitch (Easy)
      'conv_5', // Giving Difficult Feedback (Medium)
      'int_2', // Behavioral: Conflict Resolution (Medium)
      'pres_2', // Quarterly Business Review (Medium)
      'conf_1', // Ask for a Raise (Medium)
      'int_5', // Why Should We Hire You? (Medium)
      'int_4', // Salary Negotiation (Hard)
      'pres_4', // Team All-Hands Update (Medium)
      'int_3', // Technical: System Design (Hard)
    ],
  ),
  _PlanTemplate(
    id: 'social_butterfly',
    title: 'Social Confidence Path',
    description:
        'Build your social skills step by step, from small talk to deeper connections.',
    scenarioIds: [
      'soc_5', // Waiting Room Conversation (Easy)
      'soc_4', // Chat With a Neighbor (Easy)
      'soc_1', // Party Small Talk (Easy)
      'conv_1', // Networking Event Small Talk (Easy)
      'date_4', // Meeting Through Mutual Friends (Easy)
      'date_5', // Reconnecting With an Old Friend (Easy)
      'soc_3', // Dinner Party Guest (Medium)
      'date_1', // First Date Conversation (Medium)
      'date_2', // Ask Someone Out (Medium)
      'conv_2', // Asking Someone on a Date (Medium)
    ],
  ),
  _PlanTemplate(
    id: 'stage_ready',
    title: 'Stage Ready Program',
    description:
        'Go from nervous speaker to commanding the stage with confidence.',
    scenarioIds: [
      'pres_1', // Elevator Pitch (Easy)
      'story_1', // Share a Childhood Memory (Easy)
      'story_4', // A Lesson Learned (Medium)
      'pres_3', // Product Demo (Medium)
      'pub_1', // Wedding Toast (Medium)
      'deb_2', // Remote vs Office Work (Medium)
      'pub_2', // Acceptance Speech (Medium)
      'pub_3', // Motivational Talk (Hard)
      'pres_5', // Investor Pitch Deck (Hard)
      'pub_4', // TED-Style Talk (Hard)
    ],
  ),
  _PlanTemplate(
    id: 'anxiety_buster',
    title: 'Anxiety Buster',
    description:
        'Gentle, progressive practice starting with low-pressure situations to build your comfort zone.',
    scenarioIds: [
      'phone_4', // Make a Restaurant Reservation (Easy)
      'phone_1', // Order Food by Phone (Easy)
      'soc_5', // Waiting Room Conversation (Easy)
      'phone_2', // Call the Doctor's Office (Easy)
      'soc_4', // Chat With a Neighbor (Easy)
      'phone_3', // Call in Sick to Work (Medium)
      'conv_1', // Networking Small Talk (Easy)
      'phone_5', // Return an Item by Phone (Medium)
      'story_1', // Share a Childhood Memory (Easy)
      'conf_5', // Handle Criticism Gracefully (Medium)
    ],
  ),
  _PlanTemplate(
    id: 'well_rounded',
    title: 'Well-Rounded Speaker',
    description:
        'A balanced mix of speaking scenarios to develop all-around communication skills.',
    scenarioIds: [
      'soc_1', // Party Small Talk (Easy)
      'pres_1', // Elevator Pitch (Easy)
      'story_2', // Describe Your Proudest Moment (Easy)
      'int_1', // Tell Me About Yourself (Easy)
      'conv_1', // Networking Event Small Talk (Easy)
      'deb_1', // Should AI Replace Teachers? (Medium)
      'pub_1', // Wedding Toast (Medium)
      'conf_1', // Ask for a Raise (Medium)
      'pres_5', // Investor Pitch Deck (Hard)
      'pub_4', // TED-Style Talk (Hard)
    ],
  ),
];

// --- Mapping Engine ---

String matchTemplate(List<AssessmentAnswer> answers) {
  final answerMap = {for (final a in answers) a.questionId: a.optionId};

  // Priority 1: Anxiety override
  if (answerMap['challenge'] == 'anxiety') return 'anxiety_buster';

  // Priority 2: Goal-based
  switch (answerMap['goal']) {
    case 'career':
      return 'career_confidence';
    case 'social':
    case 'dating':
      return 'social_butterfly';
    case 'public':
      return 'stage_ready';
  }

  return 'well_rounded';
}

LearningPlan generatePlan(AssessmentResult result) {
  final template = _templates.firstWhere(
    (t) => t.id == result.templateId,
    orElse: () => _templates.last,
  );

  return LearningPlan(
    templateId: template.id,
    title: template.title,
    description: template.description,
    steps: template.scenarioIds
        .asMap()
        .entries
        .map((e) => PlanStep(scenarioId: e.value, order: e.key))
        .toList(),
    createdAt: DateTime.now(),
  );
}
