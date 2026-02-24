import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/feedback/domain/feedback_entity.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/feedback/presentation/providers/feedback_provider.dart';
import 'package:speech_coach/features/feedback/presentation/widgets/radar_chart.dart';
import 'package:speech_coach/features/feedback/presentation/widgets/score_bar.dart';
import 'package:speech_coach/features/progress/presentation/providers/progress_provider.dart';
import 'package:speech_coach/features/sharing/data/share_service.dart';

class ScoreCardScreen extends ConsumerStatefulWidget {
  final String scenarioId;
  final String scenarioTitle;
  final String category;

  const ScoreCardScreen({
    super.key,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.category,
  });

  @override
  ConsumerState<ScoreCardScreen> createState() => _ScoreCardScreenState();
}

class _ScoreCardScreenState extends ConsumerState<ScoreCardScreen> {
  final _screenshotController = ScreenshotController();
  bool _xpAwarded = false;

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(feedbackProvider);

    // Award XP when feedback is loaded
    if (feedbackState.status == FeedbackStatus.loaded &&
        feedbackState.feedback != null &&
        !_xpAwarded) {
      _xpAwarded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(progressProvider.notifier).addSession(feedbackState.feedback!);
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
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing your performance...',
            style: AppTypography.bodyMedium(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: AppTypography.bodySmall(
              color: context.textTertiary,
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
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.6),
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
                'Score Card',
                style: AppTypography.headlineSmall(),
              ),
              const Spacer(),
              Tappable(
                onTap: () => _shareScoreCard(feedback),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.share_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Share',
                        style:
                            AppTypography.labelMedium(color: AppColors.primary),
                      ),
                    ],
                  ),
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
                    const SizedBox(height: 8),
                    // Scenario info
                    Text(
                      widget.scenarioTitle,
                      style: AppTypography.titleLarge(),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.category,
                        style: AppTypography.labelSmall(
                          color: AppColors.primary,
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Overall score circle
                    _OverallScoreCircle(score: feedback.overallScore)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 8),
                    Text(
                      '+${feedback.xpEarned} XP',
                      style: AppTypography.titleMedium(color: AppColors.primary),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Radar chart
                    ScoreRadarChart(
                      clarity: feedback.clarity,
                      confidence: feedback.confidence,
                      engagement: feedback.engagement,
                      relevance: feedback.relevance,
                      size: 220,
                    ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                    const SizedBox(height: 24),

                    // Score bars
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detailed Scores',
                            style: AppTypography.titleMedium(),
                          ),
                          const SizedBox(height: 12),
                          ScoreBar(
                            label: 'Clarity',
                            score: feedback.clarity,
                            animationDelay: 0,
                          ),
                          ScoreBar(
                            label: 'Confidence',
                            score: feedback.confidence,
                            animationDelay: 100,
                          ),
                          ScoreBar(
                            label: 'Engagement',
                            score: feedback.engagement,
                            animationDelay: 200,
                          ),
                          ScoreBar(
                            label: 'Relevance',
                            score: feedback.relevance,
                            animationDelay: 300,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Summary
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
                          Text('Summary',
                              style: AppTypography.titleMedium()),
                          const SizedBox(height: 8),
                          Text(
                            feedback.summary,
                            style: AppTypography.bodyMedium(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Strengths
                    if (feedback.strengths.isNotEmpty)
                      _FeedbackList(
                        title: 'Strengths',
                        items: feedback.strengths,
                        icon: Icons.check_circle_rounded,
                        iconColor: AppColors.success,
                      ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    // Improvements
                    if (feedback.improvements.isNotEmpty)
                      _FeedbackList(
                        title: 'Areas to Improve',
                        items: feedback.improvements,
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.warning,
                      ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom buttons
        Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: context.divider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Tappable(
                  onTap: () => context.go('/home'),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        'Done',
                        style: AppTypography.button(
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Tappable(
                  onTap: () {
                    context.go(
                      '/scenarios/${Uri.encodeComponent(widget.category)}',
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        'Practice Again',
                        style: AppTypography.button(color: AppColors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

class _OverallScoreCircle extends StatelessWidget {
  final int score;

  const _OverallScoreCircle({required this.score});

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String get _label {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great Job!';
    if (score >= 70) return 'Good Work';
    if (score >= 50) return 'Keep Going';
    return 'Keep Practicing';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: context.divider,
                  color: _color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: AppTypography.displayLarge(color: _color),
                  ),
                  Text(
                    '/100',
                    style: AppTypography.labelSmall(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _label,
          style: AppTypography.titleLarge(color: _color),
        ),
      ],
    );
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
