import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/scenarios/domain/scenario_entity.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/scenarios/presentation/providers/scenario_provider.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';

class ScenarioListScreen extends ConsumerWidget {
  final String category;

  const ScenarioListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarios = ref.watch(scenariosByCategoryProvider(category));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Tappable(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category, style: AppTypography.headlineSmall()),
                        Text(
                          '${scenarios.length} scenarios',
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
            const SizedBox(height: 8),

            // Scenario list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: scenarios.length,
                itemBuilder: (context, index) {
                  final scenario = scenarios[index];
                  return _ScenarioCard(scenario: scenario)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        duration: 400.ms,
                      )
                      .slideX(begin: 0.05);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScenarioListSkeleton extends StatelessWidget {
  const ScenarioListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header
          const SkeletonLine(width: 160, height: 24),
          const SizedBox(height: 6),
          const SkeletonLine(width: 100, height: 14),
          const SizedBox(height: 20),
          // Scenario cards
          for (int i = 0; i < 5; i++) ...[
            Row(
              children: [
                Skeleton(
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(width: 180, height: 16),
                      const SizedBox(height: 6),
                      const SkeletonLine(height: 12),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Skeleton(
                            width: 60,
                            height: 20,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 8),
                          Skeleton(
                            width: 60,
                            height: 20,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;

  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {
        context.push(
          '/scenario/${Uri.encodeComponent(scenario.id)}',
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 80),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? context.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.divider,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
              decoration: BoxDecoration(
                color: scenario.categoryColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                scenario.icon,
                color: scenario.categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario.title,
                    style: AppTypography.titleMedium(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scenario.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(
                        label: '${scenario.durationMinutes} min',
                        icon: Icons.timer_outlined,
                      ),
                      const SizedBox(width: 8),
                      _Tag(
                        label: scenario.difficulty,
                        icon: Icons.signal_cellular_alt_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textTertiary,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Tag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.textTertiary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
