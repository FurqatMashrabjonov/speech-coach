import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speech_coach/app/constants/app_constants.dart';
import 'package:speech_coach/features/session/domain/session_entity.dart';
import 'package:speech_coach/features/session/domain/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  SessionRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _firestore.collection(AppConstants.sessionsCollection);

  @override
  Future<void> saveSession(SessionEntity session) async {
    await _sessionsRef.doc(session.id).set(session.toMap());
  }

  @override
  Future<SessionEntity?> getSession(String sessionId) async {
    final doc = await _sessionsRef.doc(sessionId).get();
    if (!doc.exists || doc.data() == null) return null;
    return SessionEntity.fromMap(doc.data()!);
  }

  @override
  Future<List<SessionEntity>> getUserSessions(String userId) async {
    final snapshot = await _sessionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SessionEntity.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<String> uploadAudio(
    String userId,
    String sessionId,
    String filePath,
  ) async {
    final ref = _storage.ref('audio/$userId/$sessionId.m4a');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}
