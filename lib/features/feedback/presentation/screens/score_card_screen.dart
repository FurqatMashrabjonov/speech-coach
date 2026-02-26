import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_images.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/feedback/domain/feedback_entity.dart';
import 'package:speech_coach/shared/widgets/coach_tip_card.dart';
import 'package:speech_coach/shared/widgets/mascot_widget.dart';
import 'package:speech_coach/shared/widgets/progress_bar.dart';
import 'package:speech_coach/shared/widgets/score_ring.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/feedback/presentation/providers/feedback_provider.dart';
import 'package:speech_coach/features/history/presentation/providers/session_history_provider.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/roast/data/roast_service.dart';
import 'package:speech_coach/features/roast/presentation/providers/roast_provider.dart';
import 'package:speech_coach/features/roast/presentation/widgets/roast_card.dart';
import 'package:speech_coach/features/roast/presentation/widgets/roast_intensity_picker.dart';
import 'package:speech_coach/features/sharing/data/share_service.dart';
import 'package:speech_coach/shared/widgets/celebration_overlay.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreCardScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  final String scenarioId;
  final String scenarioTitle;
  final String category;
  final String transcript;

  const ScoreCardScreen({
    super.key,
    this.sessionId,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.category,
    this.transcript = '',
  });

  @override
  ConsumerState<ScoreCardScreen> createState() => _ScoreCardScreenState();
}

class _ScoreCardScreenState extends ConsumerState<ScoreCardScreen> {
  final _screenshotController = ScreenshotController();
  bool _xpAwarded = false;
  bool _sessionSaved = false;
  bool _reviewChecked = false;
  bool _celebrationShown = false;

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(feedbackProvider);

    if (feedbackState.status == FeedbackStatus.loaded &&
        feedbackState.feedback != null &&
        !_xpAwarded) {
      _xpAwarded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(progressProvider.notifier).addSession(feedbackState.feedback!);

        if (!_sessionSaved) {
          _sessionSaved = true;
          if (widget.sessionId != null) {
            // New flow: update the pending session with feedback
            ref.read(pendingSessionSaverProvider).completeFeedback(
                  sessionId: widget.sessionId!,
                  feedback: feedbackState.feedback!,
                );
          } else {
            // Legacy flow: save full session at once
            ref.read(saveSessionProvider).save(
                  scenarioId: widget.scenarioId,
                  scenarioTitle: widget.scenarioTitle,
                  category: widget.category,
                  feedback: feedbackState.feedback!,
                  transcript: widget.transcript,
                );
          }
        }

        if (!_reviewChecked) {
          _reviewChecked = true;
          _maybeRequestReview(feedbackState.feedback!);
        }

        if (!_celebrationShown) {
          final progressNotifier = ref.read(progressProvider.notifier);
          if (feedbackState.feedback!.overallScore >= 80 ||
              progressNotifier.dailyGoalJustCompleted) {
            _celebrationShown = true;
            final message = progressNotifier.dailyGoalJustCompleted
                ? 'Daily Goal Complete!'
                : 'Amazing Performance!';
            _showCelebration(message);
          }
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: switch (feedbackState.status) {
          FeedbackStatus.idle || FeedbackStatus.loading => _buildLoading(),
          FeedbackStatus.loaded => _buildScoreCard(feedbackState.feedback!),
          FeedbackStatus.error => _buildError(feedbackState.error),
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MascotWidget(
            state: MascotState.thinking,
            size: 180,
          ),
          const SizedBox(height: 24),
          // Pulsing circles behind mascot
          Text(
            'Analyzing your speech...',
            style: AppTypography.headlineSmall(),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re reviewing your performance to give you\npersonalized feedback.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Processing audio',
                      style: AppTypography.labelSmall(
                        color: context.textTertiary,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                const ProgressBar(
                  value: 0.65,
                  height: 6,
                  animate: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Pro tip card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRO TIP',
                          style: AppTypography.labelSmall(
                            color: AppColors.primary,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Speaking at 120-150 words per minute is ideal for most conversations.',
                          style: AppTypography.bodySmall(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildError(String? error) {
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
              'Could not analyze conversation',
              style: AppTypography.headlineSmall(),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Tappable(
              onTap: () => context.go('/home'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Go Home',
                  style: AppTypography.labelLarge(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(ConversationFeedback feedback) {
    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Tappable(
                onTap: () => context.go('/home'),
                child: const Icon(Icons.close_rounded, size: 24),
              ),
              const Spacer(),
              Text(
                'Session Feedback',
                style: AppTypography.titleMedium(),
              ),
              const Spacer(),
              Tappable(
                onTap: () => _shareScoreCard(feedback),
                child: const Icon(
                  Icons.star_outline_rounded,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Decorative floating elements
                    SizedBox(
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 30,
                            child: Transform.rotate(
                              angle: -0.3,
                              child: Icon(
                                Icons.star_rounded,
                                size: 20,
                                color: AppColors.gold.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 40,
                            top: 10,
                            child: Transform.rotate(
                              angle: 0.4,
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 16,
                                color: AppColors.primary.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 5,
                            child: Transform.rotate(
                              angle: 0.2,
                              child: Icon(
                                Icons.celebration_rounded,
                                size: 18,
                                color: AppColors.success.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score Ring
                    Builder(
                      builder: (context) => ScoreRing(
                        score: feedback.overallScore,
                        size: 160,
                        strokeWidth: 6,
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 4),

                    // Mascot overlay
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: const MascotWidget(
                        state: MascotState.impressed,
                        size: 80,
                      ),
                    ),

                    // Label
                    Text(
                      _getScoreLabel(feedback.overallScore),
                      style: AppTypography.headlineMedium(
                        color: _getScoreColor(feedback.overallScore),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Score Breakdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Breakdown', style: AppTypography.titleMedium()),
                          const SizedBox(height: 16),
                          ProgressBar(
                            value: feedback.clarity / 100,
                            label: 'Clarity',
                            trailingText: '${feedback.clarity}%',
                            icon: Icons.waves_rounded,
                            height: 8,
                          ),
                          const SizedBox(height: 14),
                          ProgressBar(
                            value: feedback.confidence / 100,
                            label: 'Confidence',
                            trailingText: '${feedback.confidence}%',
                            icon: Icons.shield_rounded,
                            height: 8,
                          ),
                          const SizedBox(height: 14),
                          ProgressBar(
                            value: feedback.engagement / 100,
                            label: 'Engagement',
                            trailingText: '${feedback.engagement}%',
                            icon: Icons.people_rounded,
                            height: 8,
                          ),
                          const SizedBox(height: 14),
                          ProgressBar(
                            value: feedback.relevance / 100,
                            label: 'Relevance',
                            trailingText: '${feedback.relevance}%',
                            icon: Icons.track_changes_rounded,
                            height: 8,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Coach's Tip
                    CoachTipCard(
                      tip: feedback.summary.isNotEmpty
                          ? feedback.summary
                          : 'Try to maintain eye contact and use pauses effectively to emphasize key points.',
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Strengths
                    if (feedback.strengths.isNotEmpty)
                      _FeedbackList(
                        title: 'Strengths',
                        items: feedback.strengths,
                        icon: Icons.check_circle_rounded,
                        iconColor: AppColors.success,
                      ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                    if (feedback.strengths.isNotEmpty)
                      const SizedBox(height: 16),

                    // Improvements
                    if (feedback.improvements.isNotEmpty)
                      _FeedbackList(
                        title: 'Areas to Improve',
                        items: feedback.improvements,
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.warning,
                      ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom actions
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Continue Learning CTA
              Tappable(
                onTap: () => context.go(
                  '/scenarios/${Uri.encodeComponent(widget.category)}',
                ),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue Learning',
                          style: AppTypography.button(color: AppColors.white),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tappable(
                    onTap: () => context.go('/home'),
                    child: Text(
                      'Go Home',
                      style: AppTypography.labelMedium(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Tappable(
                    onTap: () => _showRoastPicker(feedback),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F525}', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          'Roast Me',
                          style: AppTypography.labelMedium(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent Work!';
    if (score >= 80) return 'Great Job!';
    if (score >= 70) return 'Good Work!';
    if (score >= 50) return 'Keep Going!';
    return 'Keep Practicing!';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  void _showCelebration(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Celebration',
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => CelebrationOverlay(
          message: message,
          onDismiss: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).maybePop();
        }
      });
    });
  }

  Future<void> _maybeRequestReview(ConversationFeedback feedback) async {
    if (feedback.overallScore < 75) return;

    final progress = ref.read(progressProvider);
    if (progress.totalSessions < 5) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_requested_review') == true) return;

    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await prefs.setBool('has_requested_review', true);
      await inAppReview.requestReview();
    }
  }

  void _showRoastPicker(ConversationFeedback feedback) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RoastIntensityPicker(
        onSelected: (intensity) {
          ref.read(roastProvider.notifier).generateRoast(
                transcript: widget.transcript,
                overallScore: feedback.overallScore,
                clarity: feedback.clarity,
                confidence: feedback.confidence,
                engagement: feedback.engagement,
                relevance: feedback.relevance,
                intensity: intensity,
              );
          _showRoastResult();
        },
      ),
    );
  }

  void _showRoastResult() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final roastState = ref.watch(roastProvider);
          if (roastState.status == RoastStatus.loading) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          if (roastState.status == RoastStatus.loaded &&
              roastState.roast != null) {
            return RoastCard(
              roastText: roastState.roast!,
              intensity: roastState.intensity ?? RoastIntensity.honest,
              scenarioTitle: widget.scenarioTitle,
            );
          }
          if (roastState.status == RoastStatus.error) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Roast failed. Even the AI was speechless.',
                  style: AppTypography.bodyMedium(
                    color: context.textSecondary,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _shareScoreCard(ConversationFeedback feedback) async {
    final image = await _screenshotController.capture();
    if (image != null) {
      await ShareService.shareScoreCardImage(
        imageBytes: image,
        scenarioTitle: widget.scenarioTitle,
        overallScore: feedback.overallScore,
      );
    }
  }
}

class _FeedbackList extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color iconColor;

  const _FeedbackList({
    required this.title,
    required this.items,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium()),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.bodyMedium(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
