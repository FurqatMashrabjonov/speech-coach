import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_images.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/conversation/presentation/providers/conversation_provider.dart';
import 'package:speech_coach/features/speaker_dna/presentation/providers/speaker_dna_provider.dart';
import 'package:speech_coach/shared/widgets/duo_button.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class SpeakerDNAQuizScreen extends ConsumerStatefulWidget {
  const SpeakerDNAQuizScreen({super.key});

  @override
  ConsumerState<SpeakerDNAQuizScreen> createState() =>
      _SpeakerDNAQuizScreenState();
}

class _SpeakerDNAQuizScreenState extends ConsumerState<SpeakerDNAQuizScreen> {
  static const _category = 'Conversations';

  static const _topics = [
    'Tell me about a moment that changed how you see the world.',
    'What would you do with an extra hour every day?',
    'Describe your perfect weekend in detail.',
    'What advice would you give your 15-year-old self?',
    'Tell me about someone who inspires you and why.',
    'What skill do you wish everyone was taught in school?',
    'Describe a risk you took that paid off.',
    'If you could master any subject overnight, what would it be?',
    'Tell me about a place that feels like home.',
    'What gets you excited to wake up in the morning?',
    'Describe a challenge you overcame recently.',
    'What would you want people to remember about you?',
    'Tell me about an unexpected friendship.',
    'What does success mean to you personally?',
    'Describe a time you changed your mind about something important.',
    'What trend do you think will shape the next decade?',
  ];

  late final String _topic;
  bool _isRecording = false;
  bool _isConnecting = false;
  int _secondsRemaining = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _topic = _topics[Random().nextInt(_topics.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dnaState = ref.watch(speakerDNAProvider);

    // Navigate to result when analysis completes
    ref.listen(speakerDNAProvider, (prev, next) {
      if (next.status == SpeakerDNAStatus.loaded && mounted) {
        context.go('/speaker-dna-result');
      }
      if (next.status == SpeakerDNAStatus.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: ${next.error}')),
        );
        setState(() => _isRecording = false);
      }
    });

    if (dnaState.status == SpeakerDNAStatus.analyzing) {
      return _buildAnalyzing();
    }

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
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.close_rounded, size: 24),
                  ),
                  const Spacer(),
                  Text('Speaker DNA', style: AppTypography.headlineSmall()),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
              const Spacer(),

              if (!_isRecording)
                Column(
                  children: [
                    Image.asset(
                      AppImages.mascotSpeak,
                      width: 200,
                      height: 200,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.primary,
                          size: 42,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 24),
                    Text(
                      'Discover Your\nSpeaker DNA',
                      style: AppTypography.displaySmall(),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    Text(
                      'Speak for 2 minutes on this topic:',
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                      ),
                      child: Text(
                        '"$_topic"',
                        style: AppTypography.titleLarge(),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),

              if (_isRecording)
                Column(
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: AppTypography.displayLarge(
                        color: _secondsRemaining <= 10
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      '"$_topic"',
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.14),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.15, 1.15),
                          duration: 800.ms,
                        ),
                  ],
                ),

              const Spacer(),

              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                child: _isConnecting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : DuoButton(
                        text: _isRecording ? 'Finish Early' : 'Start Speaking',
                        color: _isRecording ? AppColors.error : AppColors.primary,
                        shadowColor: _isRecording
                            ? const Color(0xFFCC3030)
                            : AppColors.primaryDark,
                        width: double.infinity,
                        onTap: _isRecording ? _stopRecording : _startRecording,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing your speaking DNA...',
              style: AppTypography.bodyMedium(color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'This takes a few seconds',
              style: AppTypography.bodySmall(color: context.textTertiary),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  Future<void> _startRecording() async {
    setState(() => _isConnecting = true);

    try {
      final notifier = ref.read(conversationProvider(_category).notifier);
      notifier.setScenario(
        scenarioId: 'speaker_dna',
        scenarioTitle: 'Speaker DNA Quiz',
        scenarioPrompt:
            'You are a friendly listener. The speaker is doing a 2-minute speaking exercise. '
            'Just listen attentively. Respond minimally with brief acknowledgments like '
            '"mm-hmm", "interesting", "go on" but keep your responses very short. '
            'Let them do most of the talking.',
        durationMinutes: 2,
      );
      await notifier.startConversation();

      ref.read(speakerDNAProvider.notifier).startRecording();

      setState(() {
        _isRecording = true;
        _isConnecting = false;
        _secondsRemaining = 120;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 0) {
          _stopRecording();
        }
      });
    } catch (e) {
      setState(() => _isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    final state = ref.read(conversationProvider(_category));
    final transcript = state.fullTranscript;

    await ref.read(conversationProvider(_category).notifier).endConversation();

    if (transcript.length < 50) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please speak for longer to get accurate results.'),
          ),
        );
        setState(() => _isRecording = false);
      }
      return;
    }

    ref.read(speakerDNAProvider.notifier).analyzeTranscript(transcript);
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
