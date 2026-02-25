import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/speaker_dna/data/speaker_dna_repository.dart';
import 'package:speech_coach/features/speaker_dna/data/speaker_dna_service.dart';
import 'package:speech_coach/features/speaker_dna/domain/speaker_dna_entity.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';

enum SpeakerDNAStatus { idle, recording, analyzing, loaded, error }

class SpeakerDNAState {
  final SpeakerDNAStatus status;
  final SpeakerDNA? dna;
  final String? error;

  const SpeakerDNAState({
    this.status = SpeakerDNAStatus.idle,
    this.dna,
    this.error,
  });

  SpeakerDNAState copyWith({
    SpeakerDNAStatus? status,
    SpeakerDNA? dna,
    String? error,
  }) {
    return SpeakerDNAState(
      status: status ?? this.status,
      dna: dna ?? this.dna,
      error: error ?? this.error,
    );
  }
}

class SpeakerDNANotifier extends StateNotifier<SpeakerDNAState> {
  final SpeakerDNAService _service;
  final SpeakerDNARepository _repository;

  SpeakerDNANotifier(this._service, this._repository)
      : super(const SpeakerDNAState()) {
    _loadExisting();
  }

  void _loadExisting() {
    final existing = _repository.load();
    if (existing != null) {
      state = SpeakerDNAState(
        status: SpeakerDNAStatus.loaded,
        dna: existing,
      );
    }
  }

  void startRecording() {
    state = const SpeakerDNAState(status: SpeakerDNAStatus.recording);
  }

  Future<void> analyzeTranscript(String transcript) async {
    state = const SpeakerDNAState(status: SpeakerDNAStatus.analyzing);
    try {
      final dna = await _service.analyze(transcript);
      await _repository.save(dna);
      state = SpeakerDNAState(
        status: SpeakerDNAStatus.loaded,
        dna: dna,
      );
    } catch (e) {
      state = SpeakerDNAState(
        status: SpeakerDNAStatus.error,
        error: e.toString(),
      );
    }
  }

  void reset() => state = const SpeakerDNAState();
}

final speakerDNAServiceProvider = Provider((ref) => SpeakerDNAService());

final speakerDNARepositoryProvider = Provider((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SpeakerDNARepository(prefs);
});

final speakerDNAProvider =
    StateNotifierProvider<SpeakerDNANotifier, SpeakerDNAState>((ref) {
  return SpeakerDNANotifier(
    ref.read(speakerDNAServiceProvider),
    ref.read(speakerDNARepositoryProvider),
  );
});
