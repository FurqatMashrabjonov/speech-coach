import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_coach/features/feedback/domain/feedback_entity.dart';

class ConversationFeedbackService {
  GenerativeModel? _model;

  GenerativeModel get model {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );
  }

  Future<ConversationFeedback> analyzeConversation({
    required String transcript,
    required String category,
    required String scenarioTitle,
    required String scenarioPrompt,
    required String scenarioId,
    required int durationSeconds,
  }) async {
    final prompt = '''
You are an expert speaking coach analyzing a practice conversation.

Category: $category
Scenario: $scenarioTitle
Context: $scenarioPrompt

Here is the full transcript of the conversation:
---
$transcript
---

Analyze the speaker's performance and return ONLY a valid JSON object (no markdown, no code fences) with these fields:
{
  "clarity": <1-10 score for how clear and understandable the speech was>,
  "confidence": <1-10 score for vocal projection, minimal hesitation, minimal filler words>,
  "engagement": <1-10 score for holding the listener's attention, asking good questions>,
  "relevance": <1-10 score for how well they addressed the scenario topic>,
  "overallScore": <0-100 weighted composite score>,
  "summary": "2-3 sentence summary of their performance",
  "strengths": ["strength1", "strength2", "strength3"],
  "improvements": ["specific improvement tip 1", "specific improvement tip 2", "specific improvement tip 3"]
}

Be encouraging but honest. Provide specific, actionable feedback.
The overallScore should be calculated as: (clarity + confidence + engagement + relevance) / 40 * 100, adjusted for overall impression.''';

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    return _parseResponse(
      text,
      scenarioId: scenarioId,
      category: category,
      durationSeconds: durationSeconds,
    );
  }

  ConversationFeedback _parseResponse(
    String text, {
    required String scenarioId,
    required String category,
    required int durationSeconds,
  }) {
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
      json['scenarioId'] = scenarioId;
      json['category'] = category;
      json['durationSeconds'] = durationSeconds;
      json['createdAt'] = DateTime.now().toIso8601String();
      return ConversationFeedback.fromMap(json);
    } catch (e) {
      debugPrint('Failed to parse feedback response: $e\nRaw: $text');
      return ConversationFeedback(
        clarity: 5,
        confidence: 5,
        engagement: 5,
        relevance: 5,
        overallScore: 50,
        summary: 'We had trouble analyzing your conversation. Please try again.',
        strengths: ['Keep practicing!'],
        improvements: ['Try another session for better analysis'],
        createdAt: DateTime.now(),
        scenarioId: scenarioId,
        category: category,
        durationSeconds: durationSeconds,
      );
    }
  }
}
