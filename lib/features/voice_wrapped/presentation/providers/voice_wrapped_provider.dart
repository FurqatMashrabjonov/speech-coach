import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/voice_wrapped/data/voice_wrapped_service.dart';
import 'package:speech_coach/features/voice_wrapped/domain/voice_wrapped_entity.dart';

final voiceWrappedProvider = Provider<VoiceWrapped?>((ref) {
  final progress = ref.watch(progressProvider);
  final now = DateTime.now();
  final targetMonth =
      now.month > 1 ? now.month - 1 : 12;
  final targetYear =
      now.month > 1 ? now.year : now.year - 1;
  return VoiceWrappedService.compute(progress, targetMonth, targetYear);
});
