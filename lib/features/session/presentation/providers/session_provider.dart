import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_coach/features/session/data/gemini_speech_service.dart';
import 'package:speech_coach/features/session/data/session_repository_impl.dart';
import 'package:speech_coach/features/session/domain/feedback_entity.dart';
import 'package:speech_coach/features/session/domain/session_entity.dart';
import 'package:speech_coach/features/session/domain/session_repository.dart';

// --- Repository & Service Providers ---

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl();
});

final geminiServiceProvider = Provider<GeminiSpeechService>((ref) {
  return GeminiSpeechService();
});

// --- Recording State ---

enum RecordingStatus { idle, recording, paused, stopped }

class RecordingState {
  final RecordingStatus status;
  final Duration elapsed;
  final double amplitude;
  final String? filePath;
  final String? error;

  const RecordingState({
    this.status = RecordingStatus.idle,
    this.elapsed = Duration.zero,
    this.amplitude = 0.0,
    this.filePath,
    this.error,
  });

  RecordingState copyWith({
    RecordingStatus? status,
    Duration? elapsed,
    double? amplitude,
    String? filePath,
    String? error,
  }) {
    return RecordingState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      amplitude: amplitude ?? this.amplitude,
      filePath: filePath ?? this.filePath,
      error: error,
    );
  }
}

class RecordingNotifier extends StateNotifier<RecordingState> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSub;

  RecordingNotifier() : super(const RecordingState());

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    try {
      final hasPerms = await _recorder.hasPermission();
      if (!hasPerms) {
        state = state.copyWith(
          status: RecordingStatus.idle,
          error: 'Microphone permission denied',
        );
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/session_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: path,
      );

      state = RecordingState(
        status: RecordingStatus.recording,
        filePath: path,
      );

      _startTimer();
      _startAmplitudeListener();
    } catch (e) {
      debugPrint('Recording error: $e');
      state = state.copyWith(
        status: RecordingStatus.idle,
        error: 'Failed to start recording: $e',
      );
    }
  }

  Future<void> pauseRecording() async {
    await _recorder.pause();
    _timer?.cancel();
    state = state.copyWith(status: RecordingStatus.paused);
  }

  Future<void> resumeRecording() async {
    await _recorder.resume();
    _startTimer();
    state = state.copyWith(status: RecordingStatus.recording);
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    final path = await _recorder.stop();
    state = state.copyWith(
      status: RecordingStatus.stopped,
      filePath: path ?? state.filePath,
    );
    return path ?? state.filePath;
  }

  void reset() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.stop();
    state = const RecordingState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsed: state.elapsed + const Duration(seconds: 1),
      );
    });
  }

  void _startAmplitudeListener() {
    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
      // Normalize: amp.current is typically -160 to 0 dB
      final normalized = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      state = state.copyWith(amplitude: normalized);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

final recordingProvider =
    StateNotifierProvider.autoDispose<RecordingNotifier, RecordingState>((ref) {
  return RecordingNotifier();
});

// --- Analysis State ---

class AnalysisState {
  final bool isLoading;
  final FeedbackEntity? feedback;
  final SessionEntity? session;
  final String? error;

  const AnalysisState({
    this.isLoading = false,
    this.feedback,
    this.session,
    this.error,
  });

  AnalysisState copyWith({
    bool? isLoading,
    FeedbackEntity? feedback,
    SessionEntity? session,
    String? error,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      feedback: feedback ?? this.feedback,
      session: session ?? this.session,
      error: error,
    );
  }
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final GeminiSpeechService _geminiService;
  final SessionRepository _repository;

  AnalysisNotifier(this._geminiService, this._repository)
      : super(const AnalysisState());

  Future<void> analyzeAndSave({
    required String userId,
    required String category,
    required String prompt,
    required String audioPath,
    required Duration duration,
  }) async {
    state = const AnalysisState(isLoading: true);

    try {
      // Read audio bytes
      final file = File(audioPath);
      final Uint8List audioBytes = await file.readAsBytes();

      // Analyze with Gemini
      final feedback = await _geminiService.analyzeSpeech(
        audioBytes: audioBytes,
        mimeType: 'audio/mp4',
        category: category,
        prompt: prompt,
      );

      // Create session
      final sessionId =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // Upload audio
      String? audioUrl;
      try {
        audioUrl =
            await _repository.uploadAudio(userId, sessionId, audioPath);
      } catch (e) {
        debugPrint('Audio upload failed (non-critical): $e');
      }

      final session = SessionEntity(
        id: sessionId,
        userId: userId,
        category: category,
        prompt: prompt,
        audioUrl: audioUrl,
        duration: duration,
        createdAt: DateTime.now(),
        feedback: feedback,
      );

      // Save to Firestore
      await _repository.saveSession(session);

      state = AnalysisState(
        feedback: feedback,
        session: session,
      );
    } catch (e) {
      debugPrint('Analysis error: $e');
      state = AnalysisState(error: 'Analysis failed: $e');
    }
  }

  void reset() {
    state = const AnalysisState();
  }
}

final analysisProvider =
    StateNotifierProvider.autoDispose<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(
    ref.read(geminiServiceProvider),
    ref.read(sessionRepositoryProvider),
  );
});
