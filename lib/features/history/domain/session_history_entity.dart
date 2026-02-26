import 'package:cloud_firestore/cloud_firestore.dart';

class SessionHistoryEntry {
  final String id;
  final String scenarioId;
  final String scenarioTitle;
  final String category;
  final int? overallScore;
  final int? clarity;
  final int? confidence;
  final int? engagement;
  final int? relevance;
  final String? summary;
  final List<String>? strengths;
  final List<String>? improvements;
  final String transcript;
  final int durationSeconds;
  final int? xpEarned;
  final DateTime createdAt;
  final String feedbackStatus; // "pending" | "completed" | "failed"
  final String scenarioPrompt;
  final String? feedbackGeneratedBy; // "client" | "cloud_function"

  const SessionHistoryEntry({
    required this.id,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.category,
    this.overallScore,
    this.clarity,
    this.confidence,
    this.engagement,
    this.relevance,
    this.summary,
    this.strengths,
    this.improvements,
    required this.transcript,
    required this.durationSeconds,
    this.xpEarned,
    required this.createdAt,
    this.feedbackStatus = 'completed',
    this.scenarioPrompt = '',
    this.feedbackGeneratedBy,
  });

  bool get isPending => feedbackStatus == 'pending';
  bool get isCompleted => feedbackStatus == 'completed';

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
      'feedbackStatus': feedbackStatus,
      'scenarioPrompt': scenarioPrompt,
      if (feedbackGeneratedBy != null) 'feedbackGeneratedBy': feedbackGeneratedBy,
    };
  }

  factory SessionHistoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return SessionHistoryEntry(
      id: id,
      scenarioId: map['scenarioId'] as String? ?? '',
      scenarioTitle: map['scenarioTitle'] as String? ?? '',
      category: map['category'] as String? ?? '',
      overallScore: (map['overallScore'] as num?)?.toInt(),
      clarity: (map['clarity'] as num?)?.toInt(),
      confidence: (map['confidence'] as num?)?.toInt(),
      engagement: (map['engagement'] as num?)?.toInt(),
      relevance: (map['relevance'] as num?)?.toInt(),
      summary: map['summary'] as String?,
      strengths: map['strengths'] != null
          ? List<String>.from(map['strengths'] as List)
          : null,
      improvements: map['improvements'] != null
          ? List<String>.from(map['improvements'] as List)
          : null,
      transcript: map['transcript'] as String? ?? '',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      xpEarned: (map['xpEarned'] as num?)?.toInt(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      feedbackStatus: map['feedbackStatus'] as String? ?? 'completed',
      scenarioPrompt: map['scenarioPrompt'] as String? ?? '',
      feedbackGeneratedBy: map['feedbackGeneratedBy'] as String?,
    );
  }

  factory SessionHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    return SessionHistoryEntry.fromMap(
      doc.id,
      doc.data() as Map<String, dynamic>,
    );
  }
}
