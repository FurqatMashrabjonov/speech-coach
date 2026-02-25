import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/filler_challenge/data/filler_challenge_repository.dart';
import 'package:speech_coach/features/filler_challenge/domain/filler_challenge_entity.dart';
import 'package:speech_coach/features/filler_challenge/domain/filler_detector.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';

enum FillerChallengeStatus { idle, countdown, active, ended }

class FillerChallengeState {
  final FillerChallengeStatus status;
  final int countdownValue;
  final int secondsElapsed;
  final int secondsRemaining;
  final int totalFillers;
  final Map<String, int> breakdown;
  final int? survivalSeconds;
  final String topic;
  final int personalBest;
  final FillerChallengeResult? result;

  const FillerChallengeState({
    this.status = FillerChallengeStatus.idle,
    this.countdownValue = 3,
    this.secondsElapsed = 0,
    this.secondsRemaining = 60,
    this.totalFillers = 0,
    this.breakdown = const {},
    this.survivalSeconds,
    this.topic = '',
    this.personalBest = 0,
    this.result,
  });

  FillerChallengeState copyWith({
    FillerChallengeStatus? status,
    int? countdownValue,
    int? secondsElapsed,
    int? secondsRemaining,
    int? totalFillers,
    Map<String, int>? breakdown,
    int? survivalSeconds,
    String? topic,
    int? personalBest,
    FillerChallengeResult? result,
  }) {
    return FillerChallengeState(
      status: status ?? this.status,
      countdownValue: countdownValue ?? this.countdownValue,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalFillers: totalFillers ?? this.totalFillers,
      breakdown: breakdown ?? this.breakdown,
      survivalSeconds: survivalSeconds ?? this.survivalSeconds,
      topic: topic ?? this.topic,
      personalBest: personalBest ?? this.personalBest,
      result: result ?? this.result,
    );
  }
}

class FillerChallengeNotifier extends StateNotifier<FillerChallengeState> {
  final FillerChallengeRepository _repository;
  Timer? _timer;
  Timer? _countdownTimer;
  bool _firstFillerDetected = false;
  int _prevFillerCount = 0;

  FillerChallengeNotifier(this._repository)
      : super(FillerChallengeState(personalBest: _repository.personalBest));

  void startCountdown(String topic) {
    state = FillerChallengeState(
      status: FillerChallengeStatus.countdown,
      countdownValue: 3,
      topic: topic,
      personalBest: _repository.personalBest,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdownValue <= 1) {
        timer.cancel();
        _startChallenge();
      } else {
        state = state.copyWith(countdownValue: state.countdownValue - 1);
      }
    });
  }

  void _startChallenge() {
    _firstFillerDetected = false;
    _prevFillerCount = 0;
    state = state.copyWith(
      status: FillerChallengeStatus.active,
      secondsElapsed: 0,
      secondsRemaining: 60,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining <= 1) {
        endChallenge();
      } else {
        state = state.copyWith(
          secondsElapsed: state.secondsElapsed + 1,
          secondsRemaining: state.secondsRemaining - 1,
        );
      }
    });
  }

  void onTranscriptionUpdate(String fullTranscript) {
    if (state.status != FillerChallengeStatus.active) return;

    final detected = FillerDetector.detect(fullTranscript);
    final total = detected.values.fold(0, (sum, c) => sum + c);

    if (total > _prevFillerCount) {
      // New filler detected
      HapticFeedback.heavyImpact();

      if (!_firstFillerDetected) {
        _firstFillerDetected = true;
        state = state.copyWith(
          survivalSeconds: state.secondsElapsed,
        );
      }
    }

    _prevFillerCount = total;
    state = state.copyWith(
      totalFillers: total,
      breakdown: detected,
    );
  }

  Future<void> endChallenge() async {
    _timer?.cancel();
    _countdownTimer?.cancel();

    final result = FillerChallengeResult(
      survivalSeconds:
          state.survivalSeconds ?? state.secondsElapsed,
      totalFillers: state.totalFillers,
      breakdown: Map.from(state.breakdown),
      topic: state.topic,
      createdAt: DateTime.now(),
    );

    await _repository.saveResult(result);

    state = state.copyWith(
      status: FillerChallengeStatus.ended,
      result: result,
      personalBest: _repository.personalBest,
    );
  }

  void reset() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    state = FillerChallengeState(personalBest: _repository.personalBest);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final fillerChallengeRepositoryProvider = Provider((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return FillerChallengeRepository(prefs);
});

final fillerChallengeProvider =
    StateNotifierProvider<FillerChallengeNotifier, FillerChallengeState>((ref) {
  return FillerChallengeNotifier(ref.read(fillerChallengeRepositoryProvider));
});
