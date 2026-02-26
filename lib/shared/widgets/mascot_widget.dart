import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_images.dart';

enum MascotState {
  happy,
  celebrating,
  impressed,
  thinking,
  encouraging,
  coaching,
}

class MascotWidget extends StatelessWidget {
  final MascotState state;
  final double size;
  final bool showGlow;

  const MascotWidget({
    super.key,
    required this.state,
    this.size = 120,
    this.showGlow = false,
  });

  String get _assetPath {
    switch (state) {
      case MascotState.happy:
        return AppImages.mascotHappy;
      case MascotState.celebrating:
        return AppImages.mascotCelebrate;
      case MascotState.impressed:
        return AppImages.mascotImpressed;
      case MascotState.thinking:
        return AppImages.mascotThinking;
      case MascotState.encouraging:
        return AppImages.mascotEncouraging;
      case MascotState.coaching:
        return AppImages.mascotCoaching;
    }
  }


  Color get _fallbackColor {
    switch (state) {
      case MascotState.happy:
        return AppColors.primary;
      case MascotState.celebrating:
        return AppColors.gold;
      case MascotState.impressed:
        return AppColors.primary;
      case MascotState.thinking:
        return AppColors.skyBlue;
      case MascotState.encouraging:
        return AppColors.success;
      case MascotState.coaching:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: size * 0.3,
                    spreadRadius: size * 0.05,
                  ),
                ],
              ),
            ),
          Image.asset(
            _assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildFallback(),
          ),
        ],
      ),
    );
  }

  String get _fallbackEmoji {
    switch (state) {
      case MascotState.happy:
        return '😊';
      case MascotState.celebrating:
        return '🎉';
      case MascotState.impressed:
        return '🤩';
      case MascotState.thinking:
        return '🤔';
      case MascotState.encouraging:
        return '💪';
      case MascotState.coaching:
        return '🎓';
    }
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _fallbackColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: _fallbackColor.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _fallbackEmoji,
          style: TextStyle(fontSize: size * 0.4),
        ),
      ),
    );
  }
}
