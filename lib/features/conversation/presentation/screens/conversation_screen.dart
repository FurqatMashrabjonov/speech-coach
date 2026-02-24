import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/conversation/domain/conversation_entity.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/conversation/presentation/providers/conversation_provider.dart';
import 'package:speech_coach/features/conversation/presentation/widgets/conversation_bubble.dart';
import 'package:speech_coach/features/conversation/presentation/widgets/voice_indicator.dart';
import 'package:speech_coach/features/feedback/presentation/providers/feedback_provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(conversationProvider(widget.category).notifier);

      // Set character if provided (for quick practice without scenario)
      if (widget.characterName != null && widget.scenarioId == null) {
        notifier.setCharacter(
          name: widget.characterName!,
          voiceName: widget.characterVoice ?? 'Puck',
          personality: widget.characterPersonality ?? '',
        );
      }

      // Set scenario if provided
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

      notifier.startConversation();
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

    // Auto-scroll when new messages arrive
    ref.listen(conversationProvider(widget.category), (prev, next) {
      if (prev != null && prev.messages.length != next.messages.length) {
        _scrollToBottom();
      }

      // Navigate to score card when conversation ends (scenario mode)
      if (next.status == ConversationStatus.ended &&
          next.scenarioId != null &&
          !_hasNavigatedToScoreCard &&
          next.messages.isNotEmpty) {
        _hasNavigatedToScoreCard = true;
        _navigateToScoreCard(next);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, state),
            Expanded(child: _buildMessageList(state)),
            _buildBottomControls(context, state),
          ],
        ),
      ),
    );
  }

  void _navigateToScoreCard(ConversationState state) {
    // Trigger feedback analysis
    ref.read(feedbackProvider.notifier).analyzeConversation(
          transcript: state.fullTranscript,
          category: widget.category,
          scenarioTitle: state.scenarioTitle ?? widget.category,
          scenarioPrompt: state.scenarioPrompt ?? '',
          scenarioId: state.scenarioId ?? '',
          durationSeconds: state.elapsed.inSeconds,
        );

    // Navigate to score card
    context.pushReplacement(
      '/score-card',
      extra: {
        'scenarioId': state.scenarioId ?? '',
        'scenarioTitle': state.scenarioTitle ?? widget.category,
        'category': widget.category,
      },
    );
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.scenarioTitle != null)
                  Text(
                    state.scenarioTitle!,
                    style: AppTypography.titleMedium(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.category,
                    style: AppTypography.labelSmall(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          if (state.status != ConversationStatus.idle &&
              state.status != ConversationStatus.ended)
            Tappable(
              onTap: () => _showEndDialog(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'End',
                  style: AppTypography.labelMedium(color: AppColors.error),
                ),
              ),
            ),
        ],
      ),
    );
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
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error.withValues(alpha: 0.6),
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
              Tappable(
                onTap: () {
                  ref
                      .read(conversationProvider(widget.category).notifier)
                      .startConversation();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Try Again',
                    style: AppTypography.labelLarge(color: AppColors.white),
                  ),
                ),
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
          return ConversationBubble(message: state.messages[index]);
        }
        // Live transcription indicator
        return _TypingBubble(text: state.currentTranscription);
      },
    );
  }

  Widget _buildBottomControls(BuildContext context, ConversationState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status label
          Text(
            state.isMicMuted
                ? 'Muted — Tap mic to speak'
                : _getStatusLabel(state.status),
            style: AppTypography.labelMedium(
              color: state.isMicMuted
                  ? AppColors.textTertiaryLight
                  : context.textSecondary,
            ),
          ).animate(target: 1).fadeIn(duration: 200.ms),
          const SizedBox(height: 16),

          // Voice indicator with mic mute/unmute toggle
          VoiceIndicator(
            status: state.status,
            isMuted: state.isMicMuted,
            onTap: () => ref
                .read(conversationProvider(widget.category).notifier)
                .toggleMic(),
          ),
          const SizedBox(height: 12),

          // Timer (countdown if scenario, count-up otherwise)
          if (state.isCountdown)
            _CountdownTimer(remaining: state.remaining)
          else
            Text(
              _formatDuration(state.elapsed),
              style: AppTypography.labelMedium(
                color: context.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  String _getStatusLabel(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.idle:
        return 'Ready to start';
      case ConversationStatus.connecting:
        return 'Connecting...';
      case ConversationStatus.active:
        return 'Listening...';
      case ConversationStatus.userSpeaking:
        return 'You are speaking...';
      case ConversationStatus.aiSpeaking:
        return 'AI is speaking...';
      case ConversationStatus.ended:
        return 'Conversation ended';
      case ConversationStatus.error:
        return 'Error occurred';
    }
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End Conversation?',
          style: AppTypography.headlineSmall(),
        ),
        content: Text(
          state.scenarioId != null
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
              // If no scenario, just pop back
              final currentState =
                  ref.read(conversationProvider(widget.category));
              if (currentState.scenarioId == null) {
                context.pop();
              }
              // If scenario, the listener will handle navigation to score card
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

  ConversationState get state =>
      ref.read(conversationProvider(widget.category));
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
          size: 16,
          color: isLow ? AppColors.error : context.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          '$minutes:$seconds',
          style: AppTypography.labelMedium(
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

  const _TypingBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lavender.withValues(alpha: 0.2),
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
