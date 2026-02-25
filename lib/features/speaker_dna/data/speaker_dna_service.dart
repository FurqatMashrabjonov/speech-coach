import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_coach/features/speaker_dna/domain/speaker_dna_entity.dart';

class SpeakerDNAService {
  GenerativeModel? _model;

  GenerativeModel get model {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );
  }

  Future<SpeakerDNA> analyze(String transcript) async {
    final prompt = '''
You are an expert speaking coach and personality analyst. Analyze this 2-minute speaking sample and determine the speaker's "Speaker DNA" — their natural communication archetype.

Transcript:
---
$transcript
---

Choose ONE archetype from this list:
1. The Strategic Storyteller — uses narratives and examples to make points
2. The Confident Commander — direct, authoritative, and decisive
3. The Empathetic Connector — warm, relational, builds rapport easily
4. The Analytical Thinker — logical, structured, evidence-based
5. The Enthusiastic Energizer — high energy, passionate, motivating
6. The Calm Diplomat — measured, balanced, seeks common ground
7. The Creative Visionary — imaginative, unconventional, inspiring
8. The Precise Perfectionist — detail-oriented, thorough, articulate
9. The Quick-Witted Improviser — spontaneous, humorous, adaptive
10. The Thoughtful Philosopher — reflective, deep, contemplative

Return ONLY a valid JSON object (no markdown, no code fences):
{
  "archetype": "The [Archetype Name]",
  "archetypeDescription": "2-3 sentence description of this archetype and how it manifests in their speaking",
  "topStrength1": "Their #1 speaking strength (2-4 words)",
  "topStrength2": "Their #2 speaking strength (2-4 words)",
  "growthArea": "One specific area to develop (2-4 words)",
  "famousSpeakerMatch": "Name of a famous speaker/communicator they're most like",
  "famousSpeakerReason": "One sentence explaining the match",
  "clarity": <1-10>,
  "confidence": <1-10>,
  "engagement": <1-10>,
  "relevance": <1-10>
}''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Gemini');
    }
    return _parse(text);
  }

  SpeakerDNA _parse(String text) {
    try {
      var cleaned = text.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(cleaned.indexOf('\n') + 1);
        if (cleaned.endsWith('```')) {
          cleaned = cleaned.substring(0, cleaned.lastIndexOf('```'));
        }
      }
      cleaned = cleaned.trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      json['createdAt'] = DateTime.now().toIso8601String();
      return SpeakerDNA.fromMap(json);
    } catch (e) {
      debugPrint('Failed to parse Speaker DNA response: $e\nRaw: $text');
      rethrow;
    }
  }
}
