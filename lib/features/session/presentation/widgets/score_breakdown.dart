import 'package:flutter/material.dart';
import 'package:speech_coach/features/session/domain/feedback_entity.dart';
import 'package:speech_coach/features/session/presentation/widgets/score_card.dart';

class ScoreBreakdown extends StatelessWidget {
  final FeedbackEntity feedback;

  const ScoreBreakdown({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        ScoreCard(
          label: 'Clarity',
          score: feedback.clarity,
          icon: Icons.visibility_rounded,
        ),
        ScoreCard(
          label: 'Pace',
          score: feedback.pace,
          icon: Icons.speed_rounded,
        ),
        ScoreCard(
          label: 'Filler Words',
          score: feedback.fillerWords,
          icon: Icons.text_fields_rounded,
        ),
        ScoreCard(
          label: 'Confidence',
          score: feedback.confidence,
          icon: Icons.psychology_rounded,
        ),
      ],
    );
  }
}
