import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/features/conversation/domain/conversation_entity.dart';

class VoiceIndicator extends StatefulWidget {
  final ConversationStatus status;
  final double size;
  final bool isMuted;
  final VoidCallback? onTap;

  const VoiceIndicator({
    super.key,
    required this.status,
    this.size = 88,
    this.isMuted = false,
    this.onTap,
  });

  @override
  State<VoiceIndicator> createState() => _VoiceIndicatorState();
}

class _VoiceIndicatorState extends State<VoiceIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _barController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(VoiceIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status ||
        oldWidget.isMuted != widget.isMuted) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    // Stop pulse/bar animations when mic is muted (AI bars still play)
    if (widget.isMuted) {
      _pulseController.stop();
      // Keep AI speaking bars if AI is talking
      if (widget.status == ConversationStatus.aiSpeaking) {
        _barController.repeat(reverse: true);
      } else {
        _barController.stop();
      }
      return;
    }

    switch (widget.status) {
      case ConversationStatus.userSpeaking:
        _pulseController.repeat();
        _barController.stop();
      case ConversationStatus.aiSpeaking:
        _pulseController.stop();
        _barController.repeat(reverse: true);
      case ConversationStatus.connecting:
        _pulseController.repeat();
        _barController.stop();
      default:
        _pulseController.stop();
        _barController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size + 40,
            height: widget.size + 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing rings (user speaking, not muted)
                if (widget.status == ConversationStatus.userSpeaking &&
                    !widget.isMuted)
                  ..._buildPulseRings(),

                // Connecting spinner
                if (widget.status == ConversationStatus.connecting)
                  SizedBox(
                    width: widget.size + 20,
                    height: widget.size + 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),

                // Main button
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getButtonColor(),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isMuted
                            ? AppColors.textTertiaryLight.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius:
                            widget.status == ConversationStatus.userSpeaking &&
                                    !widget.isMuted
                                ? 4
                                : 0,
                      ),
                    ],
                  ),
                  child: _buildButtonContent(),
                ),
              ],
            ),
          ),
          if (_showMuteHint) ...[
            const SizedBox(height: 8),
            Text(
              widget.isMuted ? 'Tap to unmute' : 'Tap to mute',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _showMuteHint {
    return widget.onTap != null &&
        widget.status != ConversationStatus.idle &&
        widget.status != ConversationStatus.ended &&
        widget.status != ConversationStatus.error &&
        widget.status != ConversationStatus.connecting;
  }

  Color _getButtonColor() {
    if (widget.isMuted) {
      return AppColors.textTertiaryLight;
    }
    switch (widget.status) {
      case ConversationStatus.userSpeaking:
        return AppColors.error;
      case ConversationStatus.aiSpeaking:
        return AppColors.primary.withValues(alpha: 0.5);
      case ConversationStatus.connecting:
        return AppColors.primary.withValues(alpha: 0.3);
      case ConversationStatus.ended:
      case ConversationStatus.error:
        return AppColors.textTertiaryLight;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildButtonContent() {
    if (widget.isMuted) {
      return const Icon(
        Icons.mic_off_rounded,
        color: AppColors.white,
        size: 36,
      );
    }

    if (widget.status == ConversationStatus.aiSpeaking) {
      return ClipOval(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _barController,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(5, (i) {
                  final phase = (i * 0.2 + _barController.value) % 1.0;
                  final height = 10.0 + (sin(phase * pi * 2) + 1.0) * 8.0;
                  return Container(
                    width: 4,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      );
    }

    return Icon(
      widget.status == ConversationStatus.userSpeaking
          ? Icons.stop_rounded
          : Icons.mic_rounded,
      color: AppColors.white,
      size: 36,
    );
  }

  List<Widget> _buildPulseRings() {
    return List.generate(2, (i) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final delay = i * 0.3;
          final progress = (_pulseController.value + delay) % 1.0;
          final scale = 1.0 + progress * 0.4;
          final opacity = (1.0 - progress).clamp(0.0, 0.4);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: opacity),
                  width: 2,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
