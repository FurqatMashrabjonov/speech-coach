import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';

class TextInputBar extends StatefulWidget {
  final void Function(String) onSend;
  final bool enabled;

  const TextInputBar({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<TextInputBar> createState() => _TextInputBarState();
}

class _TextInputBarState extends State<TextInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _canSend =>
      widget.enabled && _controller.text.trim().isNotEmpty;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _handleSend(),
            onChanged: (_) => setState(() {}),
            style: AppTypography.bodyMedium(),
            decoration: InputDecoration(
              hintText: 'Type your message...',
              hintStyle: AppTypography.bodyMedium(
                color: context.textTertiary,
              ),
              filled: true,
              fillColor: context.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _canSend ? _handleSend : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _canSend
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.send_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
