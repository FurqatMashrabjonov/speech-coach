import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';
import 'package:speech_coach/features/auth/presentation/providers/auth_provider.dart';
import 'package:speech_coach/features/session/domain/feedback_entity.dart';
import 'package:speech_coach/features/session/presentation/providers/session_provider.dart';
import 'package:speech_coach/features/session/presentation/widgets/feedback_section.dart';
import 'package:speech_coach/features/session/presentation/widgets/score_breakdown.dart';
import 'package:speech_coach/shared/widgets/app_button.dart';
import 'package:speech_coach/shared/widgets/loading_indicator.dart';
import 'package:speech_coach/shared/widgets/skeleton.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final String category;
  final String prompt;
  final String audioPath;
  final int durationSeconds;

  const FeedbackScreen({
    super.key,
    required this.category,
    required this.prompt,
    required this.audioPath,
    required this.durationSeconds,
  });

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  bool _transcriptExpanded = false;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    ref.read(analysisProvider.notifier).analyzeAndSave(
          userId: user.uid,
          category: widget.category,
          prompt: widget.prompt,
          audioPath: widget.audioPath,
          duration: Duration(seconds: widget.durationSeconds),
        );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(analysisProvider);
    return PopScope(
      canPop: !analysis.isLoading,
      child: Scaffold(
        body: SafeArea(
          child: analysis.isLoading
              ? _buildLoading()
              : analysis.error != null
                  ? _buildError(analysis.error!)
                  : analysis.feedback != null
                      ? _buildFeedback(analysis.feedback!)
                      : _buildLoading(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Center(
            child: Column(
              children: [
                const LoadingIndicator(size: 48),
                const SizedBox(height: 20),
                Text(
                  'Analyzing your speech...',
                  style: AppTypography.headlineMedium(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reviewing clarity, pace, confidence, and more.',
                  style: AppTypography.bodyMedium(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Score circle skeleton
          const Center(child: SkeletonCircle(size: 140)),
          const SizedBox(height: 32),

          // Score breakdown skeleton
          const SkeletonLine(width: 150, height: 20),
          const SizedBox(height: 16),
          for (int i = 0; i < 4; i++) ...[
            Skeleton(
              height: 48,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 24),

          // Strengths skeleton
          const SkeletonLine(width: 120, height: 20),
          const SizedBox(height: 12),
          Skeleton(
            height: 100,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 20),

          // Improvements skeleton
          const SkeletonLine(width: 160, height: 20),
          const SizedBox(height: 12),
          Skeleton(
            height: 100,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: AppTypography.headlineMedium(),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodyMedium(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Try Again',
              onPressed: _startAnalysis,
              isExpanded: false,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Go Home',
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/home'),
              isExpanded: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(FeedbackEntity feedback) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                Text('Session Complete!',
                    style: AppTypography.headlineLarge()),
                const SizedBox(height: 4),
                Text(
                  widget.category,
                  style: AppTypography.bodyMedium(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Overall score
          Center(
            child: _OverallScoreWidget(score: feedback.overallScore),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 32),

          // Breakdown
          Text('Score Breakdown', style: AppTypography.titleLarge()),
          const SizedBox(height: 12),
          ScoreBreakdown(feedback: feedback)
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Strengths
          if (feedback.strengths.isNotEmpty) ...[
            FeedbackSection(
              title: 'Strengths',
              items: feedback.strengths,
              isPositive: true,
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            const SizedBox(height: 20),
          ],

          // Improvements
          if (feedback.improvements.isNotEmpty) ...[
            FeedbackSection(
              title: 'Areas to Improve',
              items: feedback.improvements,
              isPositive: false,
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            const SizedBox(height: 20),
          ],

          // Detailed analysis
          if (feedback.detailedAnalysis.isNotEmpty) ...[
            Text('Detailed Analysis', style: AppTypography.titleLarge()),
            const SizedBox(height: 8),
            Text(
              feedback.detailedAnalysis,
              style: AppTypography.bodyMedium(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Transcript (expandable)
          if (feedback.transcript.isNotEmpty) ...[
            Tappable(
              onTap: () {
                setState(() => _transcriptExpanded = !_transcriptExpanded);
              },
              child: Row(
                children: [
                  Text('Transcript', style: AppTypography.titleLarge()),
                  const Spacer(),
                  Icon(
                    _transcriptExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            if (_transcriptExpanded) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  feedback.transcript,
                  style: AppTypography.bodyMedium(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],

          // Action buttons
          AppButton(
            label: 'Practice Again',
            icon: Icons.refresh_rounded,
            onPressed: () => context.pushReplacement(
              '/session/setup/${Uri.encodeComponent(widget.category)}',
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Go Home',
            variant: AppButtonVariant.outline,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OverallScoreWidget extends StatelessWidget {
  final int score;

  const _OverallScoreWidget({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
              strokeWidth: 10,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: AppTypography.displayLarge(color: AppColors.primary),
              ),
              Text(
                'Overall',
                style: AppTypography.labelMedium(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
