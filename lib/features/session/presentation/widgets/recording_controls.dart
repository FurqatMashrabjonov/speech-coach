import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/features/session/presentation/providers/session_provider.dart';

class RecordingControls extends StatelessWidget {
  final RecordingStatus status;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const RecordingControls({
    super.key,
    required this.status,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: switch (status) {
        RecordingStatus.idle => [
            _buildMainButton(
              context,
              icon: Icons.mic_rounded,
              onTap: onStart,
              color: AppColors.secondary,
              size: 88,
              filled: true,
            ),
          ],
        RecordingStatus.recording => [
            _buildMainButton(
              context,
              icon: Icons.pause_rounded,
              onTap: onPause,
              color: AppColors.primary,
              size: 64,
              filled: false,
            ),
            const SizedBox(width: 32),
            _buildMainButton(
              context,
              icon: Icons.stop_rounded,
              onTap: onStop,
              color: AppColors.secondary,
              size: 88,
              filled: true,
            ),
          ],
        RecordingStatus.paused => [
            _buildMainButton(
              context,
              icon: Icons.mic_rounded,
              onTap: onResume,
              color: AppColors.primary,
              size: 64,
              filled: false,
            ),
            const SizedBox(width: 32),
            _buildMainButton(
              context,
              icon: Icons.stop_rounded,
              onTap: onStop,
              color: AppColors.secondary,
              size: 88,
              filled: true,
            ),
          ],
        RecordingStatus.stopped => [],
      },
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required double size,
    required bool filled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : color.withValues(alpha: 0.1),
          border: filled ? null : Border.all(color: color, width: 2.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: filled ? AppColors.white : color,
          size: size * 0.4,
        ),
      ),
    );
  }
}
