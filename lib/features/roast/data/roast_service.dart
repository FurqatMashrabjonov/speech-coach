import 'package:firebase_ai/firebase_ai.dart';

enum RoastIntensity { gentle, honest, savage }

class RoastService {
  GenerativeModel? _model;

  GenerativeModel get model {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );
  }

  Future<String> generateRoast({
    required String transcript,
    required int overallScore,
    required int clarity,
    required int confidence,
    required int engagement,
    required int relevance,
    required RoastIntensity intensity,
  }) async {
    final prompt = _buildPrompt(
      transcript: transcript,
      overallScore: overallScore,
      clarity: clarity,
      confidence: confidence,
      engagement: engagement,
      relevance: relevance,
      intensity: intensity,
    );

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Empty roast response');
    }
    return text.trim();
  }

  String _buildPrompt({
    required String transcript,
    required int overallScore,
    required int clarity,
    required int confidence,
    required int engagement,
    required int relevance,
    required RoastIntensity intensity,
  }) {
    final intensityGuide = switch (intensity) {
      RoastIntensity.gentle =>
        'Be like a supportive friend who gently teases. Keep it light, '
            'encouraging, and wholesome. Think dad jokes about their speaking.',
      RoastIntensity.honest =>
        'Be like a brutally honest best friend. Point out the funny parts '
            'of their performance with wit and humor. Be real but not mean.',
      RoastIntensity.savage =>
        'Go full comedy roast mode. Be savage but clever — think stand-up '
            'comedian roasting a friend. Make it hilarious and over-the-top. '
            'No personal attacks, just roast their speaking performance.',
    };

    return '''
You are a comedy roast writer. Roast this person's speaking performance.

Their scores: Overall $overallScore/100, Clarity $clarity/10, Confidence $confidence/10, Engagement $engagement/10, Relevance $relevance/10.

Transcript excerpt:
---
${transcript.length > 500 ? transcript.substring(0, 500) : transcript}
---

Tone: $intensityGuide

Write 2-4 funny sentences roasting their speaking performance. Reference specific things from their transcript or scores. Be creative and funny.

IMPORTANT: Return ONLY the roast text, no labels or formatting.''';
  }
}
