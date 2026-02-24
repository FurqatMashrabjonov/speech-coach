import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/conversation/domain/conversation_entity.dart';
import 'package:speech_coach/features/text_chat/data/text_chat_service.dart';

// --- Providers ---

final textChatServiceProvider = Provider<TextChatService>((ref) {
  return TextChatService();
});

final textChatProvider = StateNotifierProvider.autoDispose
    .family<TextChatNotifier, TextChatState, String>((ref, category) {
  final service = ref.read(textChatServiceProvider);
  return TextChatNotifier(service, category);
});

// --- State ---

enum TextChatStatus { idle, connecting, active, aiThinking, ended, error }

class TextChatState {
  final TextChatStatus status;
  final List<ConversationMessage> messages;
  final Duration elapsed;
  final String? error;
  // Scenario fields
  final String? scenarioId;
  final String? scenarioTitle;
  final String? scenarioPrompt;
  final int? durationLimitMinutes;
  final bool isCountdown;
  // Character fields
  final String? characterName;
  final String? characterPersonality;

  const TextChatState({
    this.status = TextChatStatus.idle,
    this.messages = const [],
    this.elapsed = Duration.zero,
    this.error,
    this.scenarioId,
    this.scenarioTitle,
    this.scenarioPrompt,
    this.durationLimitMinutes,
    this.isCountdown = false,
    this.characterName,
    this.characterPersonality,
  });

  Duration get remaining {
    if (durationLimitMinutes == null) return Duration.zero;
    final limit = Duration(minutes: durationLimitMinutes!);
    final diff = limit - elapsed;
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isTimeUp =>
      durationLimitMinutes != null &&
      elapsed >= Duration(minutes: durationLimitMinutes!);

  String get fullTranscript {
    return messages
        .map((m) => '${m.role == MessageRole.user ? "User" : "AI"}: ${m.text}')
        .join('\n');
  }

  TextChatState copyWith({
    TextChatStatus? status,
    List<ConversationMessage>? messages,
    Duration? elapsed,
    String? error,
    String? scenarioId,
    String? scenarioTitle,
    String? scenarioPrompt,
    int? durationLimitMinutes,
    bool? isCountdown,
    String? characterName,
    String? characterPersonality,
  }) {
    return TextChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      elapsed: elapsed ?? this.elapsed,
      error: error,
      scenarioId: scenarioId ?? this.scenarioId,
      scenarioTitle: scenarioTitle ?? this.scenarioTitle,
      scenarioPrompt: scenarioPrompt ?? this.scenarioPrompt,
      durationLimitMinutes: durationLimitMinutes ?? this.durationLimitMinutes,
      isCountdown: isCountdown ?? this.isCountdown,
      characterName: characterName ?? this.characterName,
      characterPersonality: characterPersonality ?? this.characterPersonality,
    );
  }
}

// --- Notifier ---

class TextChatNotifier extends StateNotifier<TextChatState> {
  final TextChatService _service;
  final String category;

  Timer? _timer;

  TextChatNotifier(this._service, this.category)
      : super(const TextChatState());

  void setScenario({
    required String scenarioId,
    required String scenarioTitle,
    required String scenarioPrompt,
    required int durationMinutes,
    String? characterName,
    String? characterPersonality,
  }) {
    final fullPrompt = characterPersonality != null
        ? '$characterPersonality\n\n$scenarioPrompt'
        : scenarioPrompt;

    state = state.copyWith(
      scenarioId: scenarioId,
      scenarioTitle: scenarioTitle,
      scenarioPrompt: fullPrompt,
      durationLimitMinutes: durationMinutes,
      isCountdown: true,
      characterName: characterName,
      characterPersonality: characterPersonality,
    );
  }

  void setCharacter({
    required String name,
    required String personality,
  }) {
    state = state.copyWith(
      characterName: name,
      characterPersonality: personality,
    );
  }

  Future<void> startChat() async {
    if (state.status != TextChatStatus.idle &&
        state.status != TextChatStatus.error) {
      return;
    }

    state = state.copyWith(
      status: TextChatStatus.connecting,
      error: null,
    );

    try {
      // Build system prompt
      String? systemPrompt = state.scenarioPrompt;
      if (systemPrompt == null && state.characterPersonality != null) {
        systemPrompt = state.characterPersonality;
      }

      final baseInstruction = systemPrompt ??
          _getSystemInstruction(category);

      final fullInstruction = '$baseInstruction\n\n'
          'Keep your responses concise and conversational (2-4 sentences typically). '
          'Respond naturally as if in a real conversation. '
          'Start by greeting the user and setting the context for the $category session.';

      _service.startChat(systemPrompt: fullInstruction);
      _startTimer();

      state = state.copyWith(status: TextChatStatus.aiThinking);

      // Send initial "Hello" to get AI greeting
      final greeting = await _service.sendMessage('Hello');

      if (!mounted) return;

      if (greeting.isNotEmpty) {
        final aiMsg = ConversationMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          role: MessageRole.ai,
          text: greeting,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, aiMsg],
          status: TextChatStatus.active,
        );
      } else {
        state = state.copyWith(status: TextChatStatus.active);
      }
    } catch (e) {
      debugPrint('TextChatNotifier startChat error: $e');
      if (mounted) {
        state = state.copyWith(
          status: TextChatStatus.error,
          error: 'Failed to start chat: ${e.toString().split(':').last.trim()}',
        );
      }
    }
  }

  Future<void> sendMessage(String text) async {
    if (state.status != TextChatStatus.active || text.trim().isEmpty) return;

    final userMsg = ConversationMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      status: TextChatStatus.aiThinking,
    );

    try {
      final response = await _service.sendMessage(text.trim());

      if (!mounted) return;

      if (response.isNotEmpty) {
        final aiMsg = ConversationMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          role: MessageRole.ai,
          text: response,
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, aiMsg],
          status: TextChatStatus.active,
        );
      } else {
        state = state.copyWith(status: TextChatStatus.active);
      }
    } catch (e) {
      debugPrint('TextChatNotifier sendMessage error: $e');
      if (mounted) {
        state = state.copyWith(
          status: TextChatStatus.error,
          error: 'Failed to send message. Please try again.',
        );
      }
    }
  }

  void endChat() {
    _timer?.cancel();
    _service.close();
    if (mounted) {
      state = state.copyWith(status: TextChatStatus.ended);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        state = state.copyWith(
          elapsed: state.elapsed + const Duration(seconds: 1),
        );

        if (state.isTimeUp && state.status != TextChatStatus.ended) {
          endChat();
        }
      }
    });
  }

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
  };

  String _getSystemInstruction(String category) {
    return _personas[category] ?? _personas['Conversations']!;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.close();
    super.dispose();
  }
}
