import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/scenarios/data/scenario_repository.dart';
import 'package:speech_coach/features/scenarios/domain/scenario_entity.dart';

final scenarioRepositoryProvider = Provider<ScenarioRepository>((ref) {
  return ScenarioRepository();
});

final allScenariosProvider = Provider<List<Scenario>>((ref) {
  return ref.read(scenarioRepositoryProvider).getAllScenarios();
});

final scenariosByCategoryProvider =
    Provider.family<List<Scenario>, String>((ref, category) {
  return ref.read(scenarioRepositoryProvider).getByCategory(category);
});

final scenarioByIdProvider =
    Provider.family<Scenario?, String>((ref, id) {
  return ref.read(scenarioRepositoryProvider).getById(id);
});
