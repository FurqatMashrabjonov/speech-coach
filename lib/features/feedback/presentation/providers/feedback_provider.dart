import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/feedback/data/feedback_service.dart';
import 'package:speech_coach/features/feedback/domain/feedback_entity.dart';

final feedbackServiceProvider = Provider<ConversationFeedbackService>((ref) {
  return ConversationFeedbackService();
});

enum FeedbackStatus { idle, loading, loaded, error }

class FeedbackState {
  final FeedbackStatus status;
  final ConversationFeedback? feedback;
  final String? error;

  const FeedbackState({
    this.status = FeedbackStatus.idle,
    this.feedback,
    this.error,
  });

  FeedbackState copyWith({
    FeedbackStatus? status,
    ConversationFeedback? feedback,
    String? error,
  }) {
    return FeedbackState(
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      error: error,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  final ConversationFeedbackService _service;

  FeedbackNotifier(this._service) : super(const FeedbackState());

  Future<void> analyzeConversation({
    required String transcript,
    required String category,
    required String scenarioTitle,
    required String scenarioPrompt,
    required String scenarioId,
    required int durationSeconds,
  }) async {
    state = state.copyWith(status: FeedbackStatus.loading);

    try {
      final feedback = await _service.analyzeConversation(
        transcript: transcript,
        category: category,
        scenarioTitle: scenarioTitle,
        scenarioPrompt: scenarioPrompt,
        scenarioId: scenarioId,
        durationSeconds: durationSeconds,
      );

      state = state.copyWith(
        status: FeedbackStatus.loaded,
        feedback: feedback,
      );
    } catch (e) {
      state = state.copyWith(
        status: FeedbackStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const FeedbackState();
  }
}

final feedbackProvider =
    StateNotifierProvider.autoDispose<FeedbackNotifier, FeedbackState>((ref) {
  final service = ref.read(feedbackServiceProvider);
  return FeedbackNotifier(service);
});
