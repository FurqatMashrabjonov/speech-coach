import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/roast/data/roast_service.dart';

enum RoastStatus { idle, loading, loaded, error }

class RoastState {
  final RoastStatus status;
  final String? roast;
  final RoastIntensity? intensity;
  final String? error;

  const RoastState({
    this.status = RoastStatus.idle,
    this.roast,
    this.intensity,
    this.error,
  });

  RoastState copyWith({
    RoastStatus? status,
    String? roast,
    RoastIntensity? intensity,
    String? error,
  }) {
    return RoastState(
      status: status ?? this.status,
      roast: roast ?? this.roast,
      intensity: intensity ?? this.intensity,
      error: error ?? this.error,
    );
  }
}

class RoastNotifier extends StateNotifier<RoastState> {
  final RoastService _service;

  RoastNotifier(this._service) : super(const RoastState());

  Future<void> generateRoast({
    required String transcript,
    required int overallScore,
    required int clarity,
    required int confidence,
    required int engagement,
    required int relevance,
    required RoastIntensity intensity,
  }) async {
    state = RoastState(status: RoastStatus.loading, intensity: intensity);
    try {
      final roast = await _service.generateRoast(
        transcript: transcript,
        overallScore: overallScore,
        clarity: clarity,
        confidence: confidence,
        engagement: engagement,
        relevance: relevance,
        intensity: intensity,
      );
      state = RoastState(
        status: RoastStatus.loaded,
        roast: roast,
        intensity: intensity,
      );
    } catch (e) {
      state = RoastState(
        status: RoastStatus.error,
        error: e.toString(),
        intensity: intensity,
      );
    }
  }

  void reset() => state = const RoastState();
}

final roastServiceProvider = Provider((ref) => RoastService());

final roastProvider = StateNotifierProvider<RoastNotifier, RoastState>((ref) {
  return RoastNotifier(ref.read(roastServiceProvider));
});
