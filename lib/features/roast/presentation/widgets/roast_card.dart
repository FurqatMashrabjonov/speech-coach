import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/roast/data/roast_service.dart';
import 'package:speech_coach/features/sharing/data/share_service.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class RoastCard extends StatefulWidget {
  final String roastText;
  final RoastIntensity intensity;
  final String scenarioTitle;

  const RoastCard({
    super.key,
    required this.roastText,
    required this.intensity,
    required this.scenarioTitle,
  });

  @override
  State<RoastCard> createState() => _RoastCardState();
}

class _RoastCardState extends State<RoastCard> {
  final _screenshotController = ScreenshotController();

  int get _flameCount => switch (widget.intensity) {
        RoastIntensity.gentle => 1,
        RoastIntensity.honest => 2,
        RoastIntensity.savage => 3,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Screenshot(
            controller: _screenshotController,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.15),
                    AppColors.accent.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    List.generate(_flameCount, (_) => '\u{1F525}').join(' '),
                    style: const TextStyle(fontSize: 32),
                  ).animate().fadeIn(duration: 400.ms).scale(
                        begin: const Offset(0.5, 0.5),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 12),
                  Text(
                    'AI Roast',
                    style: AppTypography.headlineSmall(),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    widget.roastText,
                    style: AppTypography.bodyLarge(
                      color: context.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                  Text(
                    'SpeechMaster',
                    style: AppTypography.labelSmall(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Tappable(
            onTap: _share,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.share_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Share Roast',
                    style: AppTypography.button(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      await ShareService.shareScoreCardImage(
        imageBytes: image,
        scenarioTitle: widget.scenarioTitle,
        overallScore: 0,
      );
    }
  }
}
