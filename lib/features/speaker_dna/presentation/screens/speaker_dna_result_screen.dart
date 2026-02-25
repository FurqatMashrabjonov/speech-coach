import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/feedback/presentation/widgets/radar_chart.dart';
import 'package:speech_coach/features/sharing/data/share_service.dart';
import 'package:speech_coach/features/speaker_dna/domain/speaker_dna_entity.dart';
import 'package:speech_coach/features/speaker_dna/presentation/providers/speaker_dna_provider.dart';
import 'package:speech_coach/features/speaker_dna/presentation/widgets/dna_share_card.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class SpeakerDNAResultScreen extends ConsumerStatefulWidget {
  const SpeakerDNAResultScreen({super.key});

  @override
  ConsumerState<SpeakerDNAResultScreen> createState() =>
      _SpeakerDNAResultScreenState();
}

class _SpeakerDNAResultScreenState
    extends ConsumerState<SpeakerDNAResultScreen> {
  @override
  Widget build(BuildContext context) {
    final dnaState = ref.watch(speakerDNAProvider);
    final dna = dnaState.dna;

    if (dna == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No results yet', style: AppTypography.headlineSmall()),
              const SizedBox(height: 16),
              Tappable(
                onTap: () => context.go('/speaker-dna-quiz'),
                child: Text(
                  'Take the quiz',
                  style: AppTypography.labelLarge(color: AppColors.primary),
                ),
              ),
            ],
          ),
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
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.close_rounded, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    'Your Speaker DNA',
                    style: AppTypography.headlineSmall(),
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
                  children: [
                    const SizedBox(height: 16),
                    // Archetype name
                    Text(
                      dna.archetype,
                      style: AppTypography.displayMedium(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 12),
                    Text(
                      dna.archetypeDescription,
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Strengths
                    Row(
                      children: [
                        Expanded(
                          child: _BadgeChip(
                            icon: Icons.star_rounded,
                            label: dna.topStrength1,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _BadgeChip(
                            icon: Icons.star_rounded,
                            label: dna.topStrength2,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    const SizedBox(height: 10),
                    _BadgeChip(
                      icon: Icons.trending_up_rounded,
                      label: 'Growth: ${dna.growthArea}',
                      color: AppColors.warning,
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Famous speaker match
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'You speak like',
                            style: AppTypography.labelMedium(
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dna.famousSpeakerMatch,
                            style: AppTypography.headlineMedium(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dna.famousSpeakerReason,
                            style: AppTypography.bodySmall(
                              color: context.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Radar chart
                    ScoreRadarChart(
                      clarity: dna.clarity,
                      confidence: dna.confidence,
                      engagement: dna.engagement,
                      relevance: dna.relevance,
                      size: 200,
                    ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: context.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Tappable(
                      onTap: () => _share(dna),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.share_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Share',
                              style: AppTypography.button(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Tappable(
                      onTap: () => context.go('/home'),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
                            style:
                                AppTypography.button(color: AppColors.white),
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

  Future<void> _share(SpeakerDNA dna) async {
    final shareController = ScreenshotController();
    final image = await shareController.captureFromWidget(
      DNAShareCard(dna: dna),
      context: context,
    );
    await ShareService.shareScoreCardImage(
      imageBytes: image,
      scenarioTitle: 'Speaker DNA: ${dna.archetype}',
      overallScore: 0,
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelMedium(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
