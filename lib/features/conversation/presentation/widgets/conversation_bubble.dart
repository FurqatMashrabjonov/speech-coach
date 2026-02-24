import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/conversation/domain/conversation_entity.dart';

class ConversationBubble extends StatelessWidget {
  final ConversationMessage message;

  const ConversationBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            _AiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isUser
                    ? AppColors.primary
                    : AppColors.lavender.withValues(alpha: 0.3),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(_isUser ? 20 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTypography.bodyMedium(
                      color: _isUser
                          ? AppColors.white
                          : context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.labelSmall(
                      color: _isUser
                          ? AppColors.white.withValues(alpha: 0.7)
                          : context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUser) const SizedBox(width: 40),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: _isUser ? 0.1 : -0.1, duration: 300.ms);
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
