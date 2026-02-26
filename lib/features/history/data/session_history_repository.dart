import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/history/domain/session_history_entity.dart';

class SessionHistoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SessionHistoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _sessionsRef {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('sessions');
  }

  Future<void> saveSession(SessionHistoryEntry entry) async {
    await _sessionsRef.doc(entry.id).set(entry.toMap());
  }

  Future<String> savePendingSession({
    required String scenarioId,
    required String scenarioTitle,
    required String category,
    required String transcript,
    required int durationSeconds,
    required String scenarioPrompt,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = SessionHistoryEntry(
      id: id,
      scenarioId: scenarioId,
      scenarioTitle: scenarioTitle,
      category: category,
      transcript: transcript,
      durationSeconds: durationSeconds,
      createdAt: DateTime.now(),
      feedbackStatus: 'pending',
      scenarioPrompt: scenarioPrompt,
    );
    await _sessionsRef.doc(id).set(entry.toMap());
    return id;
  }

  Future<void> updateSessionWithFeedback({
    required String sessionId,
    required int overallScore,
    required int clarity,
    required int confidence,
    required int engagement,
    required int relevance,
    required String summary,
    required List<String> strengths,
    required List<String> improvements,
    required int xpEarned,
  }) async {
    await _sessionsRef.doc(sessionId).update({
      'overallScore': overallScore,
      'clarity': clarity,
      'confidence': confidence,
      'engagement': engagement,
      'relevance': relevance,
      'summary': summary,
      'strengths': strengths,
      'improvements': improvements,
      'xpEarned': xpEarned,
      'feedbackStatus': 'completed',
      'feedbackGeneratedBy': 'client',
    });
  }

  Future<List<SessionHistoryEntry>> getSessions({int limit = 50}) async {
    final snapshot = await _sessionsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SessionHistoryEntry.fromFirestore(doc))
        .toList();
  }

  Future<SessionHistoryEntry?> getSession(String id) async {
    final doc = await _sessionsRef.doc(id).get();
    if (!doc.exists) return null;
    return SessionHistoryEntry.fromFirestore(doc);
  }

  Future<void> deleteSession(String id) async {
    await _sessionsRef.doc(id).delete();
  }
}

final sessionHistoryRepositoryProvider = Provider<SessionHistoryRepository>(
  (ref) => SessionHistoryRepository(),
);
