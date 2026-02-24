import 'package:speech_coach/features/session/domain/feedback_entity.dart';

class SessionEntity {
  final String id;
  final String userId;
  final String category;
  final String prompt;
  final String? audioUrl;
  final Duration duration;
  final DateTime createdAt;
  final FeedbackEntity? feedback;

  const SessionEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.prompt,
    this.audioUrl,
    required this.duration,
    required this.createdAt,
    this.feedback,
  });

  factory SessionEntity.fromMap(Map<String, dynamic> map) {
    return SessionEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      category: map['category'] as String,
      prompt: map['prompt'] as String,
      audioUrl: map['audioUrl'] as String?,
      duration: Duration(seconds: (map['durationSeconds'] as num).toInt()),
      createdAt: DateTime.parse(map['createdAt'] as String),
      feedback: map['feedback'] != null
          ? FeedbackEntity.fromMap(map['feedback'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'prompt': prompt,
      'audioUrl': audioUrl,
      'durationSeconds': duration.inSeconds,
      'createdAt': createdAt.toIso8601String(),
      'feedback': feedback?.toMap(),
    };
  }

  SessionEntity copyWith({
    String? id,
    String? userId,
    String? category,
    String? prompt,
    String? audioUrl,
    Duration? duration,
    DateTime? createdAt,
    FeedbackEntity? feedback,
  }) {
    return SessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      prompt: prompt ?? this.prompt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      feedback: feedback ?? this.feedback,
    );
  }
}
