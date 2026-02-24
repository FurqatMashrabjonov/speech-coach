import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_coach/features/characters/domain/character_entity.dart';
import 'package:speech_coach/shared/providers/user_provider.dart';

final selectedCharacterProvider =
    StateNotifierProvider<SelectedCharacterNotifier, AICharacter>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SelectedCharacterNotifier(prefs);
});

class SelectedCharacterNotifier extends StateNotifier<AICharacter> {
  static const _key = 'selected_character_id';
  final SharedPreferences _prefs;

  SelectedCharacterNotifier(this._prefs)
      : super(CharacterRepository.defaultCharacter) {
    _load();
  }

  void _load() {
    final id = _prefs.getString(_key);
    if (id != null) {
      state = CharacterRepository.getById(id);
    }
  }

  void select(AICharacter character) {
    state = character;
    _prefs.setString(_key, character.id);
  }
}

final charactersForCategoryProvider =
    Provider.family<List<AICharacter>, String>((ref, category) {
  return CharacterRepository.getForCategory(category);
});
