import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:record/record.dart';
import 'package:speech_coach/features/conversation/data/gemini_live_service.dart';
import 'package:speech_coach/features/conversation/domain/conversation_entity.dart';

// --- Providers ---

final geminiLiveServiceProvider = Provider<GeminiLiveService>((ref) {
  return GeminiLiveService();
});

final conversationProvider = StateNotifierProvider.autoDispose
    .family<ConversationNotifier, ConversationState, String>((ref, category) {
  final service = ref.read(geminiLiveServiceProvider);
  return ConversationNotifier(service, category);
});

// --- State ---

class ConversationState {
  final ConversationStatus status;
  final List<ConversationMessage> messages;
  final String currentTranscription;
  final String? error;
  final Duration elapsed;
  // Scenario fields
  final String? scenarioId;
  final String? scenarioTitle;
  final String? scenarioPrompt;
  final int? durationLimitMinutes;
  final bool isCountdown;
  // Character fields
  final String? characterName;
  final String? characterVoice;
  final String? characterPersonality;
  // Mic mute state
  final bool isMicMuted;

  const ConversationState({
    this.status = ConversationStatus.idle,
    this.messages = const [],
    this.currentTranscription = '',
    this.error,
    this.elapsed = Duration.zero,
    this.scenarioId,
    this.scenarioTitle,
    this.scenarioPrompt,
    this.durationLimitMinutes,
    this.isCountdown = false,
    this.characterName,
    this.characterVoice,
    this.characterPersonality,
    this.isMicMuted = false,
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

  ConversationState copyWith({
    ConversationStatus? status,
    List<ConversationMessage>? messages,
    String? currentTranscription,
    String? error,
    Duration? elapsed,
    String? scenarioId,
    String? scenarioTitle,
    String? scenarioPrompt,
    int? durationLimitMinutes,
    bool? isCountdown,
    String? characterName,
    String? characterVoice,
    String? characterPersonality,
    bool? isMicMuted,
  }) {
    return ConversationState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      currentTranscription: currentTranscription ?? this.currentTranscription,
      error: error,
      elapsed: elapsed ?? this.elapsed,
      scenarioId: scenarioId ?? this.scenarioId,
      scenarioTitle: scenarioTitle ?? this.scenarioTitle,
      scenarioPrompt: scenarioPrompt ?? this.scenarioPrompt,
      durationLimitMinutes: durationLimitMinutes ?? this.durationLimitMinutes,
      isCountdown: isCountdown ?? this.isCountdown,
      characterName: characterName ?? this.characterName,
      characterVoice: characterVoice ?? this.characterVoice,
      characterPersonality: characterPersonality ?? this.characterPersonality,
      isMicMuted: isMicMuted ?? this.isMicMuted,
    );
  }
}

// --- Notifier ---

class ConversationNotifier extends StateNotifier<ConversationState> {
  final GeminiLiveService _service;
  final String category;
  final AudioRecorder _recorder = AudioRecorder();

  Timer? _timer;
  bool _closed = false;
  StreamSubscription<List<int>>? _micSubscription;

  // SoLoud streaming audio playback — raw PCM fed directly, no WAV wrapping
  AudioSource? _audioStream;
  SoundHandle? _audioHandle;

  // Keep a copy of all audio for the message bubble
  final List<int> _turnAudioBuffer = [];
  // Buffer for user speech transcription (from inputTranscription)
  String _pendingUserTranscription = '';

  ConversationNotifier(this._service, this.category)
      : super(const ConversationState());

  void setScenario({
    required String scenarioId,
    required String scenarioTitle,
    required String scenarioPrompt,
    required int durationMinutes,
    String? characterName,
    String? characterVoice,
    String? characterPersonality,
  }) {
    // If character personality is provided, prepend it to the scenario prompt
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
      characterVoice: characterVoice,
      characterPersonality: characterPersonality,
    );
  }

  void setCharacter({
    required String name,
    required String voiceName,
    required String personality,
  }) {
    state = state.copyWith(
      characterName: name,
      characterVoice: voiceName,
      characterPersonality: personality,
    );
  }

  /// Initialize SoLoud engine and set up a buffer stream for audio playback.
  Future<void> _initAudioPlayer() async {
    if (!SoLoud.instance.isInitialized) {
      await SoLoud.instance.init(
        sampleRate: 24000,
        channels: Channels.mono,
      );
    }
    await _setupNewStream();
  }

  Future<void> _setupNewStream() async {
    if (!SoLoud.instance.isInitialized) return;

    // Stop previous stream if active
    await _stopAudioStream();

    _audioStream = SoLoud.instance.setBufferStream(
      maxBufferSizeBytes: 1024 * 1024 * 10, // 10MB max (not pre-allocated)
      bufferingType: BufferingType.released,
      bufferingTimeNeeds: 0,
      onBuffering: (isBuffering, handle, time) {},
    );
    _audioHandle = null;
  }

  Future<void> _startAudioPlayback() async {
    if (_audioStream == null) return;
    _audioHandle = await SoLoud.instance.play(_audioStream!);
  }

  Future<void> _stopAudioStream() async {
    if (_audioStream != null &&
        _audioHandle != null &&
        SoLoud.instance.getIsValidVoiceHandle(_audioHandle!)) {
      SoLoud.instance.setDataIsEnded(_audioStream!);
      await SoLoud.instance.stop(_audioHandle!);
    }
    _audioStream = null;
    _audioHandle = null;
  }

  Future<void> startConversation() async {
    if (state.status != ConversationStatus.idle &&
        state.status != ConversationStatus.error) {
      return;
    }

    state = state.copyWith(
      status: ConversationStatus.connecting,
      error: null,
    );

    try {
      final hasPerms = await _recorder.hasPermission();
      if (!hasPerms) {
        state = state.copyWith(
          status: ConversationStatus.error,
          error: 'Microphone permission denied',
        );
        return;
      }

      // Initialize SoLoud audio player
      await _initAudioPlayer();

      // Build system prompt with character personality if available
      String? systemPrompt = state.scenarioPrompt;
      if (systemPrompt == null && state.characterPersonality != null) {
        systemPrompt = state.characterPersonality;
      }

      await _service.connect(
        category,
        customSystemPrompt: systemPrompt,
        voiceName: state.characterVoice,
      );
      _startTimer();

      // Start receive loop (runs in background)
      _receiveLoop();

      // Start audio playback stream (SoLoud auto-pauses when buffer empty)
      await _startAudioPlayback();

      // Trigger AI to speak first (greeting)
      await _service.sendText('Hello');

      // Start mic after AI has been triggered so greeting isn't interrupted
      _startMicStream();

      state = state.copyWith(status: ConversationStatus.aiSpeaking);
    } catch (e) {
      debugPrint('Start conversation error: $e');
      state = state.copyWith(
        status: ConversationStatus.error,
        error: 'Failed to connect: ${e.toString().split(':').last.trim()}',
      );
    }
  }

  /// Starts continuous mic audio streaming to Gemini via per-chunk sendAudioRealtime.
  /// VAD on the server automatically detects when the user speaks/stops.
  Future<void> _startMicStream() async {
    try {
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // Send each audio chunk individually via sendAudioRealtime
      _micSubscription = stream.listen((data) {
        _service.sendAudioRealtime(Uint8List.fromList(data));
      });
    } catch (e) {
      debugPrint('Mic stream error: $e');
    }
  }

  /// Toggle mic mute/unmute. When muted, stops the recorder so no audio
  /// is sent to Gemini. When unmuted, restarts the mic stream.
  Future<void> toggleMic() async {
    if (state.status == ConversationStatus.idle ||
        state.status == ConversationStatus.ended ||
        state.status == ConversationStatus.error ||
        state.status == ConversationStatus.connecting) {
      return;
    }

    if (!state.isMicMuted) {
      // Mute: stop recorder and cancel subscription
      await _micSubscription?.cancel();
      _micSubscription = null;
      try {
        await _recorder.stop();
      } catch (_) {}
      state = state.copyWith(isMicMuted: true);
    } else {
      // Unmute: restart mic stream
      await _startMicStream();
      state = state.copyWith(isMicMuted: false);
    }
  }

  /// Continuously calls receive() in a loop. Each call yields responses
  /// until turnComplete, then we call receive() again for the next turn.
  Future<void> _receiveLoop() async {
    while (!_closed && _service.isConnected) {
      try {
        await for (final response in _service.receive()) {
          if (_closed) break;
          _handleServerResponse(response);
        }
        // receive() stream ended (turnComplete). Flush user transcription
        // as a message, then loop back for next turn.
        _flushUserTranscription();
      } catch (e) {
        if (_closed) break;
        debugPrint('Receive loop error: $e');
        if (mounted) {
          final errorStr = e.toString();
          String userError;
          if (errorStr.contains('invalid argument')) {
            userError = 'Invalid configuration. Please try again.';
          } else if (errorStr.contains('WebSocket Closed')) {
            userError = 'Connection closed by server. Please try again.';
          } else {
            userError = 'Connection lost. Please try again.';
          }
          state = state.copyWith(
            status: ConversationStatus.error,
            error: userError,
          );
        }
        break;
      }
    }
  }

  void _handleServerResponse(LiveServerResponse response) {
    final msg = response.message;

    if (msg is LiveServerContent) {
      // Audio chunks from model turn — feed directly to SoLoud stream
      if (msg.modelTurn != null) {
        if (state.status != ConversationStatus.aiSpeaking) {
          state = state.copyWith(status: ConversationStatus.aiSpeaking);
        }
        for (final part in msg.modelTurn!.parts) {
          if (part is InlineDataPart &&
              part.mimeType.startsWith('audio')) {
            // Save for the message bubble
            _turnAudioBuffer.addAll(part.bytes);
            // Feed directly to SoLoud — no WAV wrapping, no buffering
            if (_audioStream != null) {
              SoLoud.instance.addAudioDataStream(
                _audioStream!,
                part.bytes,
              );
            }
          }
        }
      }

      // AI output transcription (what the AI is saying as text)
      if (msg.outputTranscription?.text != null) {
        state = state.copyWith(
          currentTranscription:
              state.currentTranscription + msg.outputTranscription!.text!,
        );
      }

      // User input transcription (what the user said)
      if (msg.inputTranscription?.text != null) {
        final newText = msg.inputTranscription!.text!;
        _pendingUserTranscription += newText;

        if (state.status == ConversationStatus.active && newText.trim().isNotEmpty) {
          state = state.copyWith(status: ConversationStatus.userSpeaking);
        }
      }

      // Turn is complete — create the AI message bubble (audio already playing)
      if (msg.turnComplete == true) {
        _onAiTurnComplete();
      }
    }
  }

  /// Flush any accumulated user transcription into a user message bubble.
  void _flushUserTranscription() {
    final userText = _pendingUserTranscription.trim();
    if (userText.isNotEmpty) {
      _pendingUserTranscription = '';
      final userMsg = ConversationMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.user,
        text: userText,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, userMsg],
      );
    }
  }

  Future<void> _onAiTurnComplete() async {
    // Signal end of data for this stream segment
    if (_audioStream != null) {
      SoLoud.instance.setDataIsEnded(_audioStream!);
    }

    final transcription = state.currentTranscription.trim();
    Uint8List? audioBytes;

    // Grab the full audio from this turn (already played via stream)
    if (_turnAudioBuffer.isNotEmpty) {
      audioBytes = Uint8List.fromList(_turnAudioBuffer);
      _turnAudioBuffer.clear();
    }

    if (transcription.isNotEmpty || audioBytes != null) {
      final aiMsg = ConversationMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.ai,
        text: transcription.isNotEmpty ? transcription : 'AI response',
        audioBytes: audioBytes,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        currentTranscription: '',
        status: ConversationStatus.active,
      );
    } else {
      state = state.copyWith(
        currentTranscription: '',
        status: ConversationStatus.active,
      );
    }

    // Set up a new stream for the next AI turn
    await _setupNewStream();
    if (_audioStream != null) {
      await _startAudioPlayback();
    }
  }

  Future<void> endConversation() async {
    _closed = true;
    _timer?.cancel();

    await _micSubscription?.cancel();
    _micSubscription = null;
    try {
      await _recorder.stop();
    } catch (_) {}

    await _stopAudioStream();
    await _service.close();

    if (mounted) {
      state = state.copyWith(status: ConversationStatus.ended);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        state = state.copyWith(
          elapsed: state.elapsed + const Duration(seconds: 1),
        );

        // Auto-end when time limit is reached
        if (state.isTimeUp && state.status != ConversationStatus.ended) {
          endConversation();
        }
      }
    });
  }

  @override
  void dispose() {
    _closed = true;
    _timer?.cancel();
    _micSubscription?.cancel();
    _recorder.dispose();
    _stopAudioStream();
    _service.close();
    super.dispose();
  }
}
