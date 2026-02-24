import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/conversation/presentation/widgets/conversation_bubble.dart';
import 'package:speech_coach/features/feedback/presentation/providers/feedback_provider.dart';
import 'package:speech_coach/features/text_chat/presentation/providers/text_chat_provider.dart';
import 'package:speech_coach/features/text_chat/presentation/widgets/text_input_bar.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class TextChatScreen extends ConsumerStatefulWidget {
  final String category;
  final String? scenarioId;
  final String? scenarioTitle;
  final String? scenarioPrompt;
  final int? durationMinutes;
  final String? characterName;
  final String? characterPersonality;

  const TextChatScreen({
    super.key,
    required this.category,
    this.scenarioId,
    this.scenarioTitle,
    this.scenarioPrompt,
    this.durationMinutes,
    this.characterName,
    this.characterPersonality,
  });

  @override
  ConsumerState<TextChatScreen> createState() => _TextChatScreenState();
}

class _TextChatScreenState extends ConsumerState<TextChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasNavigatedToScoreCard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(textChatProvider(widget.category).notifier);

      // Set character if provided (for quick practice without scenario)
      if (widget.characterName != null && widget.scenarioId == null) {
        notifier.setCharacter(
          name: widget.characterName!,
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
          characterPersonality: widget.characterPersonality,
        );
      }

      notifier.startChat();
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
    final state = ref.watch(textChatProvider(widget.category));

    // Auto-scroll when new messages arrive
    ref.listen(textChatProvider(widget.category), (prev, next) {
      if (prev != null && prev.messages.length != next.messages.length) {
        _scrollToBottom();
      }

      // Navigate to score card when chat ends (scenario mode)
      if (next.status == TextChatStatus.ended &&
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

  void _navigateToScoreCard(TextChatState state) {
    ref.read(feedbackProvider.notifier).analyzeConversation(
          transcript: state.fullTranscript,
          category: widget.category,
          scenarioTitle: state.scenarioTitle ?? widget.category,
          scenarioPrompt: state.scenarioPrompt ?? '',
          scenarioId: state.scenarioId ?? '',
          durationSeconds: state.elapsed.inSeconds,
        );

    context.pushReplacement(
      '/score-card',
      extra: {
        'scenarioId': state.scenarioId ?? '',
        'scenarioTitle': state.scenarioTitle ?? widget.category,
        'category': widget.category,
      },
    );
  }

  Widget _buildAppBar(BuildContext context, TextChatState state) {
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.category,
                        style:
                            AppTypography.labelSmall(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lavender.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_rounded,
                              size: 12, color: AppColors.lavender),
                          const SizedBox(width: 3),
                          Text(
                            'Text',
                            style: AppTypography.labelSmall(
                                color: AppColors.lavender),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.status != TextChatStatus.idle &&
              state.status != TextChatStatus.ended)
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

  Widget _buildMessageList(TextChatState state) {
    if (state.status == TextChatStatus.connecting) {
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
              'Starting chat...',
              style: AppTypography.bodyMedium(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == TextChatStatus.error) {
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
                      .read(textChatProvider(widget.category).notifier)
                      .startChat();
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

    final showTypingBubble = state.status == TextChatStatus.aiThinking;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length + (showTypingBubble ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.messages.length) {
          return ConversationBubble(message: state.messages[index]);
        }
        // AI thinking indicator
        return _TypingBubble();
      },
    );
  }

  Widget _buildBottomControls(BuildContext context, TextChatState state) {
    final isInputEnabled = state.status == TextChatStatus.active;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status label
          Text(
            _getStatusLabel(state.status),
            style: AppTypography.labelMedium(
              color: context.textSecondary,
            ),
          ).animate(target: 1).fadeIn(duration: 200.ms),
          const SizedBox(height: 10),

          // Text input bar
          TextInputBar(
            onSend: (text) {
              ref
                  .read(textChatProvider(widget.category).notifier)
                  .sendMessage(text);
            },
            enabled: isInputEnabled,
          ),
          const SizedBox(height: 8),

          // Timer (countdown if scenario, count-up otherwise)
          if (state.isCountdown)
            _CountdownTimer(remaining: state.remaining)
          else if (state.status != TextChatStatus.idle &&
              state.status != TextChatStatus.connecting)
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

  String _getStatusLabel(TextChatStatus status) {
    switch (status) {
      case TextChatStatus.idle:
        return 'Ready';
      case TextChatStatus.connecting:
        return 'Connecting...';
      case TextChatStatus.active:
        return 'Your turn';
      case TextChatStatus.aiThinking:
        return 'AI is thinking...';
      case TextChatStatus.ended:
        return 'Chat ended';
      case TextChatStatus.error:
        return 'Error occurred';
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleBack(BuildContext context) {
    final state = ref.read(textChatProvider(widget.category));
    if (state.status != TextChatStatus.idle &&
        state.status != TextChatStatus.ended &&
        state.status != TextChatStatus.error) {
      _showEndDialog(context);
    } else {
      context.pop();
    }
  }

  void _showEndDialog(BuildContext context) {
    final chatState = ref.read(textChatProvider(widget.category));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'End Chat?',
          style: AppTypography.headlineSmall(),
        ),
        content: Text(
          chatState.scenarioId != null
              ? 'This will end your session and generate your score card.'
              : 'This will end your current text chat session.',
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
                  .read(textChatProvider(widget.category).notifier)
                  .endChat();
              // If no scenario, just pop back
              final currentState =
                  ref.read(textChatProvider(widget.category));
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(
                    'AI is thinking...',
                    style: AppTypography.bodyMedium(
                      color: context.textSecondary,
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
