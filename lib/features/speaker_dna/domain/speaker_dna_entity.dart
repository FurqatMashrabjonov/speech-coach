class SpeakerDNA {
  final String archetype;
  final String archetypeDescription;
  final String topStrength1;
  final String topStrength2;
  final String growthArea;
  final String famousSpeakerMatch;
  final String famousSpeakerReason;
  final int clarity;
  final int confidence;
  final int engagement;
  final int relevance;
  final DateTime createdAt;

  const SpeakerDNA({
    required this.archetype,
    required this.archetypeDescription,
    required this.topStrength1,
    required this.topStrength2,
    required this.growthArea,
    required this.famousSpeakerMatch,
    required this.famousSpeakerReason,
    required this.clarity,
    required this.confidence,
    required this.engagement,
    required this.relevance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'archetype': archetype,
      'archetypeDescription': archetypeDescription,
      'topStrength1': topStrength1,
      'topStrength2': topStrength2,
      'growthArea': growthArea,
      'famousSpeakerMatch': famousSpeakerMatch,
      'famousSpeakerReason': famousSpeakerReason,
      'clarity': clarity,
      'confidence': confidence,
      'engagement': engagement,
      'relevance': relevance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SpeakerDNA.fromMap(Map<String, dynamic> map) {
    return SpeakerDNA(
      archetype: map['archetype'] as String? ?? 'The Conversationalist',
      archetypeDescription:
          map['archetypeDescription'] as String? ?? '',
      topStrength1: map['topStrength1'] as String? ?? '',
      topStrength2: map['topStrength2'] as String? ?? '',
      growthArea: map['growthArea'] as String? ?? '',
      famousSpeakerMatch: map['famousSpeakerMatch'] as String? ?? '',
      famousSpeakerReason: map['famousSpeakerReason'] as String? ?? '',
      clarity: (map['clarity'] as num?)?.toInt() ?? 5,
      confidence: (map['confidence'] as num?)?.toInt() ?? 5,
      engagement: (map['engagement'] as num?)?.toInt() ?? 5,
      relevance: (map['relevance'] as num?)?.toInt() ?? 5,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
