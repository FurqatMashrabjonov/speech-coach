import 'package:cloud_firestore/cloud_firestore.dart';

class SessionHistoryEntry {
  final String id;
  final String scenarioId;
  final String scenarioTitle;
  final String category;
  final int overallScore;
  final int clarity;
  final int confidence;
  final int engagement;
  final int relevance;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String transcript;
  final int durationSeconds;
  final int xpEarned;
  final DateTime createdAt;

  const SessionHistoryEntry({
    required this.id,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.category,
    required this.overallScore,
    required this.clarity,
    required this.confidence,
    required this.engagement,
    required this.relevance,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.transcript,
    required this.durationSeconds,
    required this.xpEarned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'scenarioId': scenarioId,
      'scenarioTitle': scenarioTitle,
      'category': category,
      'overallScore': overallScore,
      'clarity': clarity,
      'confidence': confidence,
      'engagement': engagement,
      'relevance': relevance,
      'summary': summary,
      'strengths': strengths,
      'improvements': improvements,
      'transcript': transcript,
      'durationSeconds': durationSeconds,
      'xpEarned': xpEarned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SessionHistoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return SessionHistoryEntry(
      id: id,
      scenarioId: map['scenarioId'] as String? ?? '',
      scenarioTitle: map['scenarioTitle'] as String? ?? '',
      category: map['category'] as String? ?? '',
      overallScore: (map['overallScore'] as num?)?.toInt() ?? 0,
      clarity: (map['clarity'] as num?)?.toInt() ?? 0,
      confidence: (map['confidence'] as num?)?.toInt() ?? 0,
      engagement: (map['engagement'] as num?)?.toInt() ?? 0,
      relevance: (map['relevance'] as num?)?.toInt() ?? 0,
      summary: map['summary'] as String? ?? '',
      strengths: List<String>.from(map['strengths'] as List? ?? []),
      improvements: List<String>.from(map['improvements'] as List? ?? []),
      transcript: map['transcript'] as String? ?? '',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory SessionHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    return SessionHistoryEntry.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }
}
