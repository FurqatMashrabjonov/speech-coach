import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiLiveService {
  LiveSession? _session;

  static const _personas = {
    'Presentations':
        'You are a professional audience member attending a presentation. '
            'Ask clarifying questions about the content, provide engaged reactions, '
            'and give constructive feedback on delivery. Be encouraging but realistic.',
    'Interviews':
        'You are a hiring manager conducting a job interview. '
            'Ask a mix of behavioral and technical questions. Be professional, '
            'listen carefully, and follow up on answers. Start by introducing yourself '
            'and the role.',
    'Public Speaking':
        'You are a speech coach giving real-time guidance. '
            'Provide feedback on delivery, tone, pacing, and structure. '
            'Encourage the speaker and suggest improvements naturally in conversation.',
    'Conversations':
        'You are a friendly conversation partner. '
            'Engage naturally, ask thoughtful follow-up questions, share relevant thoughts, '
            'and keep the conversation flowing. Be warm and personable.',
    'Debates':
        'You are a debate opponent. Present counterarguments respectfully, '
            'challenge points with evidence-based reasoning, and acknowledge strong arguments. '
            'Be firm but fair in your positions.',
    'Storytelling':
        'You are an engaged story listener. React naturally to the narrative, '
            'ask about details, express genuine curiosity, and encourage the storyteller '
            'to elaborate on interesting points.',
    'Phone Anxiety':
        'You are the person on the other end of a phone call. '
            'Respond naturally as if this is a real phone conversation. '
            'Be helpful but realistic — ask clarifying questions and keep it professional.',
    'Dating & Social':
        'You are a potential romantic interest or social acquaintance. '
            'Be warm, genuine, and naturally engaged. React authentically and keep '
            'the conversation flowing with a mix of sharing and curiosity.',
    'Conflict & Boundaries':
        'You are the person the speaker needs to have a difficult conversation with. '
            'Be realistic — show some resistance initially, then gradually respond '
            'to good communication. Test their assertiveness and empathy.',
    'Social Situations':
        'You are a person in a social setting meeting the speaker. '
            'Be friendly and open. Engage naturally in small talk, share about yourself, '
            'and keep the conversation comfortable and flowing.',
  };

  String _getSystemInstruction(String category) {
    final persona = _personas[category] ?? _personas['Conversations']!;
    return '$persona\n\n'
        'Keep your responses concise and conversational (2-4 sentences typically). '
        'Speak naturally as if in a real conversation. '
        'Start by greeting the user and setting the context for the $category session.';
  }

  Future<void> connect(
    String category, {
    String? customSystemPrompt,
    String? voiceName,
  }) async {
    try {
      final systemInstruction = customSystemPrompt != null
          ? '$customSystemPrompt\n\n'
              'Keep your responses concise and conversational (2-4 sentences typically). '
              'Speak naturally as if in a real conversation.'
          : _getSystemInstruction(category);

      final liveModel = FirebaseAI.googleAI().liveGenerativeModel(
        model: 'gemini-2.5-flash-native-audio-preview-12-2025',
        systemInstruction: Content.text(systemInstruction),
        liveGenerationConfig: LiveGenerationConfig(
          responseModalities: [ResponseModalities.audio],
          speechConfig: voiceName != null
              ? SpeechConfig(voiceName: voiceName)
              : null,
          inputAudioTranscription: AudioTranscriptionConfig(),
          outputAudioTranscription: AudioTranscriptionConfig(),
        ),
      );

      _session = await liveModel.connect();
    } catch (e) {
      debugPrint('GeminiLiveService connect error: $e');
      rethrow;
    }
  }

  /// Returns a stream for the current turn. Completes on turnComplete.
  /// Call again for each new turn.
  Stream<LiveServerResponse> receive() {
    if (_session == null) {
      return const Stream.empty();
    }
    return _session!.receive();
  }

  /// Continuously streams mic audio to the session. VAD handles turn detection.
  Future<void> startMediaStream(Stream<Uint8List> audioStream) async {
    if (_session == null) return;
    try {
      final mediaStream = audioStream.map(
        (data) => InlineDataPart('audio/pcm', Uint8List.fromList(data)),
      );
      // ignore: deprecated_member_use
      await _session!.sendMediaStream(mediaStream);
    } catch (e) {
      debugPrint('GeminiLiveService startMediaStream error: $e');
    }
  }

  /// Send a text message to trigger the AI to speak (e.g., greeting).
  Future<void> sendText(String text) async {
    if (_session == null) return;
    await _session!.send(
      input: Content('user', [TextPart(text)]),
      turnComplete: true,
    );
  }

  /// Send a single audio chunk in real-time (replaces deprecated sendMediaStream).
  Future<void> sendAudioRealtime(Uint8List pcmData) async {
    if (_session == null) return;
    await _session!.sendAudioRealtime(InlineDataPart('audio/pcm', pcmData));
  }

  Future<void> close() async {
    try {
      await _session?.close();
    } catch (e) {
      debugPrint('GeminiLiveService close error: $e');
    }
    _session = null;
  }

  bool get isConnected => _session != null;
}
