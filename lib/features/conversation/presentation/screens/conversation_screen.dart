import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_images.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/characters/domain/character_entity.dart';
import 'package:speech_coach/features/conversation/domain/conversation_entity.dart';
import 'package:speech_coach/shared/widgets/duo_button.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/conversation/presentation/providers/conversation_provider.dart';
import 'package:speech_coach/features/profile/presentation/providers/settings_provider.dart';
import 'package:speech_coach/features/conversation/presentation/widgets/conversation_bubble.dart';
import 'package:speech_coach/features/feedback/presentation/providers/feedback_provider.dart';
import 'package:speech_coach/features/history/presentation/providers/session_history_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String category;
  final String? scenarioId;
  final String? scenarioTitle;
  final String? scenarioPrompt;
  final int? durationMinutes;
  final String? characterName;
  final String? characterVoice;
  final String? characterPersonality;

  const ConversationScreen({
    super.key,
    required this.category,
    this.scenarioId,
    this.scenarioTitle,
    this.scenarioPrompt,
    this.durationMinutes,
    this.characterName,
    this.characterVoice,
    this.characterPersonality,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasNavigatedToScoreCard = false;
  bool _showGetReady = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(conversationProvider(widget.category).notifier);

      if (widget.characterName != null && widget.scenarioId == null) {
        notifier.setCharacter(
          name: widget.characterName!,
          voiceName: widget.characterVoice ?? ref.read(defaultVoiceProvider),
          personality: widget.characterPersonality ?? '',
        );
      }

      if (widget.scenarioId != null) {
        notifier.setScenario(
          scenarioId: widget.scenarioId!,
          scenarioTitle: widget.scenarioTitle ?? widget.category,
          scenarioPrompt: widget.scenarioPrompt ?? '',
          durationMinutes: widget.durationMinutes ?? 3,
          characterName: widget.characterName,
          characterVoice: widget.characterVoice,
          characterPersonality: widget.characterPersonality,
        );
      }

      // Show "Get Ready" overlay for 2 seconds, then start
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showGetReady = false);
          notifier.startConversation();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider(widget.category));

    ref.listen(conversationProvider(widget.category), (prev, next) {
      if (prev != null && prev.messages.length != next.messages.length) {
        _scrollToBottom();
      }

      if (next.status == ConversationStatus.ended &&
          next.scenarioId != null &&
          !_hasNavigatedToScoreCard &&
          next.messages.isNotEmpty) {
        _hasNavigatedToScoreCard = true;
        _navigateToScoreCard(next);
      }
    });

    if (_showGetReady) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.scenarioTitle ?? widget.category,
                  style: AppTypography.headlineMedium(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'AI will speak first.\nListen, then respond naturally.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(
                      color: context.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, state),
            if (state.status != ConversationStatus.connecting &&
                state.status != ConversationStatus.error)
              _buildCharacterHeader(context, state),
            Expanded(child: _buildMessageList(state)),
            _buildBottomPanel(context, state),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToScoreCard(ConversationState state) async {
    // 1. Try to save transcript to Firestore (non-blocking on failure)
    String? sessionId;
    try {
      sessionId = await ref.read(pendingSessionSaverProvider).savePending(
        scenarioId: state.scenarioId ?? '',
        scenarioTitle: state.scenarioTitle ?? widget.category,
        category: widget.category,
        transcript: state.fullTranscript,
        durationSeconds: state.elapsed.inSeconds,
        scenarioPrompt: state.scenarioPrompt ?? '',
      );
    } catch (e) {
      debugPrint('Failed to save session to Firestore: $e');
      // Continue without sessionId — score card still works
    }

    // 2. Kick off client-side feedback
    ref.read(feedbackProvider.notifier).analyzeConversation(
          transcript: state.fullTranscript,
          category: widget.category,
          scenarioTitle: state.scenarioTitle ?? widget.category,
          scenarioPrompt: state.scenarioPrompt ?? '',
          scenarioId: state.scenarioId ?? '',
          durationSeconds: state.elapsed.inSeconds,
        );

    // 3. Navigate with sessionId (may be null if Firestore failed)
    if (mounted) {
      context.pushReplacement(
        '/score-card',
        extra: {
          'sessionId': sessionId,
          'scenarioId': state.scenarioId ?? '',
          'scenarioTitle': state.scenarioTitle ?? widget.category,
          'category': widget.category,
          'transcript': state.fullTranscript,
        },
      );
    }
  }

  Widget _buildAppBar(BuildContext context, ConversationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Tappable(
            onTap: () => _handleBack(context),
            child: const Icon(Icons.arrow_back_rounded, size: 24),
          ),
          const Spacer(),
          // Online indicator
          if (state.status == ConversationStatus.active ||
              state.status == ConversationStatus.userSpeaking ||
              state.status == ConversationStatus.aiSpeaking)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ONLINE',
                    style: AppTypography.labelSmall(
                      color: AppColors.success,
                    ).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          if (state.status != ConversationStatus.idle &&
              state.status != ConversationStatus.ended)
            Tappable(
              onTap: () => _showEndDialog(context),
              child: const Icon(Icons.more_horiz_rounded, size: 24),
            )
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildCharacterHeader(BuildContext context, ConversationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Character avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _characterImagePath != null
                  ? Image.asset(
                      _characterImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultCharacterAvatar(),
                    )
                  : _defaultCharacterAvatar(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.characterName ?? 'AI Coach',
            style: AppTypography.titleMedium(),
          ),
          Text(
            'Native English Speaker',
            style: AppTypography.labelSmall(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          // Date pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatDatePill(),
              style: AppTypography.labelSmall(
                color: context.textTertiary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _defaultCharacterAvatar() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.auto_awesome,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  String _formatDatePill() {
    final now = DateTime.now();
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return 'Today, ${months[now.month]} ${now.day} · $h:$m';
  }

  Widget _buildMessageList(ConversationState state) {
    if (state.status == ConversationStatus.connecting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Connecting...',
              style: AppTypography.bodyMedium(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == ConversationStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppImages.mascotError,
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              DuoButton.primary(
                text: 'Try Again',
                onTap: () {
                  ref
                      .read(conversationProvider(widget.category).notifier)
                      .startConversation();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (state.messages.isEmpty && state.currentTranscription.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Listening...', style: AppTypography.titleMedium(color: context.textTertiary)),
              const SizedBox(height: 8),
              Text(
                'AI will speak first, then respond naturally.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(color: context.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length +
          (state.currentTranscription.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.messages.length) {
          return ConversationBubble(
            message: state.messages[index],
            characterImagePath: _characterImagePath,
          );
        }
        return _TypingBubble(
          text: state.currentTranscription,
          characterImagePath: _characterImagePath,
        );
      },
    );
  }

  Widget _buildBottomPanel(BuildContext context, ConversationState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E5E5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Audio waveform
          if (state.status == ConversationStatus.aiSpeaking ||
              state.status == ConversationStatus.userSpeaking)
            _AudioWaveform(
              isUserSpeaking: state.status == ConversationStatus.userSpeaking,
            ),
          if (state.status == ConversationStatus.aiSpeaking ||
              state.status == ConversationStatus.userSpeaking)
            const SizedBox(height: 12),

          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer for layout balance
              const SizedBox(width: 44),
              const SizedBox(width: 24),

              // Large mic button
              GestureDetector(
                onTap: () => ref
                    .read(conversationProvider(widget.category).notifier)
                    .toggleMic(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: state.isMicMuted
                        ? null
                        : AppColors.primaryGradient,
                    color: state.isMicMuted
                        ? AppColors.textTertiaryLight
                        : null,
                    shape: BoxShape.circle,
                    boxShadow: state.isMicMuted
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primaryDark,
                              blurRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    state.isMicMuted
                        ? Icons.mic_off_rounded
                        : Icons.mic_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Stop button
              Tappable(
                onTap: () => _showEndDialog(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stop_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.isMicMuted ? 'Tap to unmute' : 'Tap to speak',
            style: AppTypography.labelSmall(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 4),

          // Timer
          if (state.isCountdown)
            _CountdownTimer(remaining: state.remaining)
          else
            Text(
              _formatDuration(state.elapsed),
              style: AppTypography.labelSmall(
                color: context.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleBack(BuildContext context) {
    final state = ref.read(conversationProvider(widget.category));
    if (state.status != ConversationStatus.idle &&
        state.status != ConversationStatus.ended &&
        state.status != ConversationStatus.error) {
      _showEndDialog(context);
    } else {
      context.pop();
    }
  }

  void _showEndDialog(BuildContext context) {
    final currentState = ref.read(conversationProvider(widget.category));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End Conversation?',
          style: AppTypography.headlineSmall(),
        ),
        content: Text(
          currentState.scenarioId != null
              ? 'This will end your session and generate your score card.'
              : 'This will end your current conversation session.',
          style: AppTypography.bodyMedium(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge(
                color: context.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(conversationProvider(widget.category).notifier)
                  .endConversation();
              final s = ref.read(conversationProvider(widget.category));
              if (s.scenarioId == null) {
                context.pop();
              }
            },
            child: Text(
              'End',
              style: AppTypography.labelLarge(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String? get _characterImagePath {
    final name = widget.characterName;
    if (name == null) return null;
    try {
      return CharacterRepository.characters
          .firstWhere((c) => c.name == name)
          .imagePath;
    } catch (_) {
      return null;
    }
  }
}

class _AudioWaveform extends StatefulWidget {
  final bool isUserSpeaking;

  const _AudioWaveform({required this.isUserSpeaking});

  @override
  State<_AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<_AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (i) {
            final phase = (i * 0.15 + _controller.value) % 1.0;
            final height = 8.0 + (sin(phase * pi * 2) + 1.0) * 8.0;
            final opacity = 0.3 + (sin(phase * pi * 2) + 1.0) * 0.35;
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  final Duration remaining;

  const _CountdownTimer({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final isLow = remaining.inSeconds <= 30;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 14,
          color: isLow ? AppColors.error : context.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          '$minutes:$seconds',
          style: AppTypography.labelSmall(
            color: isLow ? AppColors.error : context.textTertiary,
          ),
        ),
        if (isLow)
          Text(
            ' remaining',
            style: AppTypography.labelSmall(color: AppColors.error),
          ),
      ],
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final String text;
  final String? characterImagePath;

  const _TypingBubble({required this.text, this.characterImagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          characterImagePath != null
              ? ClipOval(
                  child: Image.asset(
                    characterImagePath!,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.chatAiBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      text.isNotEmpty ? text : 'AI is thinking...',
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
