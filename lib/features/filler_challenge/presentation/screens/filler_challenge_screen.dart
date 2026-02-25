import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/conversation/presentation/providers/conversation_provider.dart';
import 'package:speech_coach/features/filler_challenge/presentation/providers/filler_challenge_provider.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class FillerChallengeScreen extends ConsumerStatefulWidget {
  const FillerChallengeScreen({super.key});

  @override
  ConsumerState<FillerChallengeScreen> createState() =>
      _FillerChallengeScreenState();
}

class _FillerChallengeScreenState extends ConsumerState<FillerChallengeScreen> {
  static const _category = 'Conversations';

  static const _topics = [
    'Explain why your favorite movie is worth watching.',
    'Describe what you did last weekend in detail.',
    'Talk about a hobby you love and why it matters to you.',
    'Explain how to cook your favorite meal.',
    'Describe your ideal vacation destination.',
    'Talk about a book or show that changed your perspective.',
    'Explain what you do for work to a 10-year-old.',
    'Describe the most interesting person you have ever met.',
    'Talk about a goal you are working toward right now.',
    'Explain why a skill you have is useful.',
    'Describe your morning routine in detail.',
    'Talk about a recent news story that interested you.',
    'Explain the rules of your favorite game or sport.',
    'Describe what makes a great friend.',
    'Talk about a place you would love to visit and why.',
    'Explain a topic you know well to a complete beginner.',
    'Describe the best meal you have ever had.',
    'Talk about something you recently learned.',
    'Explain why you chose your current career path.',
    'Describe your hometown to someone who has never been there.',
  ];

  late final String _topic;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _topic = _topics[Random().nextInt(_topics.length)];
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(fillerChallengeProvider);

    // Navigate on end
    ref.listen(fillerChallengeProvider, (prev, next) {
      if (next.status == FillerChallengeStatus.ended && mounted) {
        context.go('/filler-result');
      }
    });

    // Feed transcription to detector
    ref.listen(conversationProvider(_category), (prev, next) {
      if (challengeState.status == FillerChallengeStatus.active &&
          next.fullTranscript.isNotEmpty) {
        ref
            .read(fillerChallengeProvider.notifier)
            .onTranscriptionUpdate(next.fullTranscript);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Tappable(
                    onTap: () {
                      ref.read(fillerChallengeProvider.notifier).reset();
                      ref
                          .read(conversationProvider(_category).notifier)
                          .endConversation();
                      context.go('/home');
                    },
                    child: const Icon(Icons.close_rounded, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    'Filler Challenge',
                    style: AppTypography.headlineSmall(),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
              const Spacer(),

              // Countdown
              if (challengeState.status == FillerChallengeStatus.countdown)
                Text(
                  '${challengeState.countdownValue}',
                  style: AppTypography.displayLarge(color: AppColors.primary),
                )
                    .animate(
                        key: ValueKey(challengeState.countdownValue),
                        onPlay: (c) => c.forward())
                    .fadeIn(duration: 200.ms)
                    .scale(begin: const Offset(1.5, 1.5)),

              // Idle state
              if (challengeState.status == FillerChallengeStatus.idle)
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.whatshot_rounded,
                        color: AppColors.accent,
                        size: 42,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Filler Word\nChallenge',
                      style: AppTypography.displaySmall(),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    Text(
                      'Speak for 60 seconds without saying "um", "uh", "like", or other filler words.',
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your topic:',
                            style: AppTypography.labelSmall(
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _topic,
                            style: AppTypography.titleMedium(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    if (challengeState.personalBest > 0) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Personal best: ${challengeState.personalBest}s',
                        style: AppTypography.labelMedium(
                          color: AppColors.primary,
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                    ],
                  ],
                ),

              // Active state
              if (challengeState.status == FillerChallengeStatus.active)
                Column(
                  children: [
                    Text(
                      '${challengeState.secondsRemaining}',
                      style: AppTypography.displayLarge(
                        color: challengeState.secondsRemaining <= 10
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'seconds remaining',
                      style: AppTypography.bodySmall(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: challengeState.totalFillers > 0
                            ? AppColors.error.withValues(alpha: 0.14)
                            : AppColors.primary.withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        color: challengeState.totalFillers > 0
                            ? AppColors.error
                            : AppColors.primary,
                        size: 48,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.15, 1.15),
                          duration: 800.ms,
                        ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: challengeState.totalFillers > 0
                            ? AppColors.error.withValues(alpha: 0.14)
                            : AppColors.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        challengeState.totalFillers > 0
                            ? '${challengeState.totalFillers} fillers detected'
                            : 'Clean so far!',
                        style: AppTypography.titleMedium(
                          color: challengeState.totalFillers > 0
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _topic,
                      style: AppTypography.bodySmall(
                        color: context.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              const Spacer(),

              if (challengeState.status == FillerChallengeStatus.idle ||
                  challengeState.status == FillerChallengeStatus.active)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Tappable(
                    onTap: _isConnecting
                        ? null
                        : challengeState.status == FillerChallengeStatus.active
                            ? _endChallenge
                            : _startChallenge,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: challengeState.status ==
                                FillerChallengeStatus.active
                            ? AppColors.error
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: _isConnecting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                challengeState.status ==
                                        FillerChallengeStatus.active
                                    ? 'End Challenge'
                                    : 'Start Challenge',
                                style: AppTypography.button(
                                    color: AppColors.white),
                              ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startChallenge() async {
    setState(() => _isConnecting = true);
    try {
      final notifier = ref.read(conversationProvider(_category).notifier);
      notifier.setScenario(
        scenarioId: 'filler_challenge',
        scenarioTitle: 'Filler Word Challenge',
        scenarioPrompt:
            'You are listening to someone speak. Stay completely silent. '
            'Do NOT respond, do NOT speak, do NOT make any sounds. '
            'Just listen quietly.',
        durationMinutes: 1,
      );
      await notifier.startConversation();

      ref.read(fillerChallengeProvider.notifier).startCountdown(_topic);
      setState(() => _isConnecting = false);
    } catch (e) {
      setState(() => _isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start: $e')),
        );
      }
    }
  }

  Future<void> _endChallenge() async {
    await ref.read(fillerChallengeProvider.notifier).endChallenge();
    await ref
        .read(conversationProvider(_category).notifier)
        .endConversation();
  }
}
