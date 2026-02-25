class FillerChallengeResult {
  final int survivalSeconds;
  final int totalFillers;
  final Map<String, int> breakdown;
  final String topic;
  final DateTime createdAt;

  const FillerChallengeResult({
    required this.survivalSeconds,
    required this.totalFillers,
    required this.breakdown,
    required this.topic,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'survivalSeconds': survivalSeconds,
      'totalFillers': totalFillers,
      'breakdown': breakdown,
      'topic': topic,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FillerChallengeResult.fromMap(Map<String, dynamic> map) {
    return FillerChallengeResult(
      survivalSeconds: (map['survivalSeconds'] as num?)?.toInt() ?? 0,
      totalFillers: (map['totalFillers'] as num?)?.toInt() ?? 0,
      breakdown: Map<String, int>.from(map['breakdown'] as Map? ?? {}),
      topic: map['topic'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
