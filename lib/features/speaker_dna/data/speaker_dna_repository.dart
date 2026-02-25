import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_coach/features/speaker_dna/domain/speaker_dna_entity.dart';

class SpeakerDNARepository {
  static const _key = 'speaker_dna';

  final SharedPreferences _prefs;

  SpeakerDNARepository(this._prefs);

  SpeakerDNA? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return SpeakerDNA.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(SpeakerDNA dna) async {
    await _prefs.setString(_key, jsonEncode(dna.toMap()));
    _saveRemote(dna);
  }

  Future<void> _saveRemote(SpeakerDNA dna) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('data')
          .doc('speaker_dna')
          .set(dna.toMap());
    } catch (e) {
      debugPrint('SpeakerDNA remote save error: $e');
    }
  }
}
