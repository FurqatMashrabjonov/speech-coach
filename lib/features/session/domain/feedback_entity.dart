class FeedbackEntity {
  final int overallScore;
  final int clarity;
  final int pace;
  final int fillerWords;
  final int confidence;
  final List<String> strengths;
  final List<String> improvements;
  final String transcript;
  final String detailedAnalysis;

  const FeedbackEntity({
    required this.overallScore,
    required this.clarity,
    required this.pace,
    required this.fillerWords,
    required this.confidence,
    required this.strengths,
    required this.improvements,
    required this.transcript,
    required this.detailedAnalysis,
  });

  factory FeedbackEntity.fromMap(Map<String, dynamic> map) {
    return FeedbackEntity(
      overallScore: (map['overallScore'] as num).toInt(),
      clarity: (map['clarity'] as num).toInt(),
      pace: (map['pace'] as num).toInt(),
      fillerWords: (map['fillerWords'] as num).toInt(),
      confidence: (map['confidence'] as num).toInt(),
      strengths: List<String>.from(map['strengths'] as List),
      improvements: List<String>.from(map['improvements'] as List),
      transcript: map['transcript'] as String? ?? '',
      detailedAnalysis: map['detailedAnalysis'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallScore': overallScore,
      'clarity': clarity,
      'pace': pace,
      'fillerWords': fillerWords,
      'confidence': confidence,
      'strengths': strengths,
      'improvements': improvements,
      'transcript': transcript,
      'detailedAnalysis': detailedAnalysis,
    };
  }
}
