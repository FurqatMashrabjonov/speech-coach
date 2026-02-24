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
