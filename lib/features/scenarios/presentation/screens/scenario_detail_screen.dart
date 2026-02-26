import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/characters/domain/character_entity.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/characters/presentation/providers/character_provider.dart';
import 'package:speech_coach/features/paywall/data/usage_service.dart';
import 'package:speech_coach/features/scenarios/domain/scenario_entity.dart';
import 'package:speech_coach/features/scenarios/presentation/providers/scenario_provider.dart';

class ScenarioDetailScreen extends ConsumerWidget {
  final String scenarioId;

  const ScenarioDetailScreen({super.key, required this.scenarioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenario = ref.watch(scenarioByIdProvider(scenarioId));
    final selectedCharacter = ref.watch(selectedCharacterProvider);

    if (scenario == null) {
      return Scaffold(
        body: Center(
          child: Text('Scenario not found', style: AppTypography.bodyMedium()),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Tappable(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded, size: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scenario.categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      scenario.category,
                      style: AppTypography.labelMedium(
                        color: scenario.categoryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: scenario.categoryColor.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        scenario.icon,
                        color: scenario.categoryColor,
                        size: 40,
                      ),
                    ).animate().fadeIn(duration: 400.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      scenario.title,
                      style: AppTypography.displaySmall(),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      scenario.description,
                      style: AppTypography.bodyLarge(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                    const SizedBox(height: 32),

                    // Details row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DetailChip(
                          icon: Icons.timer_outlined,
                          label: '${scenario.durationMinutes} min',
                        ),
                        const SizedBox(width: 12),
                        _DetailChip(
                          icon: Icons.signal_cellular_alt_rounded,
                          label: scenario.difficulty,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 28),

                    // Character picker
                    _CharacterPicker(
                      category: scenario.category,
                      selectedCharacter: selectedCharacter,
                      onSelect: (character) {
                        ref
                            .read(selectedCharacterProvider.notifier)
                            .select(character);
                      },
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                    const SizedBox(height: 28),

                    // Tips
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tips', style: AppTypography.titleMedium()),
                          const SizedBox(height: 12),
                          _TipRow(
                            icon: Icons.mic_rounded,
                            text: 'Speak clearly and at a natural pace',
                          ),
                          const SizedBox(height: 8),
                          _TipRow(
                            icon: Icons.access_time_rounded,
                            text:
                                'You have ${scenario.durationMinutes} minutes — use them wisely',
                          ),
                          const SizedBox(height: 8),
                          _TipRow(
                            icon: Icons.chat_rounded,
                            text:
                                '${selectedCharacter.name} will respond naturally — engage with them',
                          ),
                          const SizedBox(height: 8),
                          _TipRow(
                            icon: Icons.star_rounded,
                            text:
                                'You\'ll receive a detailed score card after',
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Start buttons (Voice + Text)
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  // Voice Practice button (primary)
                  Expanded(
                    flex: 3,
                    child: Tappable(
                      onTap: () => _startPractice(
                          context, ref, scenario, selectedCharacter,
                          mode: 'voice'),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mic_rounded,
                                  color: AppColors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Voice Practice',
                                style:
                                    AppTypography.button(color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Text Chat button (outline)
                  Expanded(
                    flex: 2,
                    child: Tappable(
                      onTap: () => _startPractice(
                          context, ref, scenario, selectedCharacter,
                          mode: 'text'),
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.keyboard_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Text Chat',
                                style: AppTypography.button(
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startPractice(BuildContext context, WidgetRef ref, Scenario scenario,
      AICharacter character, {String mode = 'voice'}) {
    final usageService = ref.read(usageServiceProvider);
    if (!usageService.canStartSession()) {
      context.push('/paywall');
      return;
    }

    usageService.recordSession();

    final route = mode == 'text'
        ? '/text-chat/${Uri.encodeComponent(scenario.category)}'
        : '/conversation/${Uri.encodeComponent(scenario.category)}';

    context.push(
      route,
      extra: {
        'scenarioId': scenario.id,
        'scenarioTitle': scenario.title,
        'scenarioPrompt': scenario.systemPrompt,
        'durationMinutes': scenario.durationMinutes,
        'characterName': character.name,
        'characterVoice': character.voiceName,
        'characterPersonality': character.personality,
      },
    );
  }
}

class _CharacterPicker extends StatelessWidget {
  final String category;
  final AICharacter selectedCharacter;
  final void Function(AICharacter) onSelect;

  const _CharacterPicker({
    required this.category,
    required this.selectedCharacter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final recommended = CharacterRepository.getForCategory(category);
    final allCharacters = CharacterRepository.characters;

    // Show recommended first, then others
    final ordered = [
      ...recommended,
      ...allCharacters.where((c) => !recommended.contains(c)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your AI partner', style: AppTypography.titleMedium()),
        const SizedBox(height: 4),
        Text(
          'Each character has a unique voice and personality',
          style: AppTypography.bodySmall(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ordered.length,
            itemBuilder: (context, index) {
              final character = ordered[index];
              final isSelected = character.id == selectedCharacter.id;
              final isRecommended = recommended.contains(character);

              return Tappable(
                onTap: () => onSelect(character),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? character.color.withValues(alpha: 0.22)
                        : context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? character.color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          character.imagePath,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: character.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                character.avatarEmoji,
                                style: AppTypography.titleMedium(
                                  color: character.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        character.name,
                        style: AppTypography.labelSmall(
                          color: isSelected
                              ? character.color
                              : context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isRecommended && index < recommended.length)
                        Text(
                          'Best fit',
                          style: AppTypography.labelSmall(
                            color: context.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Selected character description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selectedCharacter.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  selectedCharacter.imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    selectedCharacter.icon,
                    color: selectedCharacter.color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCharacter.name,
                      style: AppTypography.labelMedium(
                        color: selectedCharacter.color,
                      ),
                    ),
                    Text(
                      selectedCharacter.description,
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style:
                AppTypography.labelMedium(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium(
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
