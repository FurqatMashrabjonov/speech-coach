import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/shared/widgets/app_button.dart';
import 'package:speech_coach/shared/widgets/app_card.dart';

class SessionSetupScreen extends ConsumerWidget {
  final String category;
  final String? challengePrompt;

  const SessionSetupScreen({
    super.key,
    required this.category,
    this.challengePrompt,
  });

  static const _categoryPrompts = {
    'Presentations': [
      'Present your favorite product to a potential investor.',
      'Explain a complex concept to a non-technical audience.',
      'Give a 2-minute project status update to your team.',
    ],
    'Interviews': [
      'Tell me about yourself and your experience.',
      'Describe a challenging situation and how you handled it.',
      'Why should we hire you for this position?',
    ],
    'Public Speaking': [
      'Give an inspirational speech about overcoming challenges.',
      'Deliver a persuasive argument for renewable energy.',
      'Make an announcement at a company all-hands meeting.',
    ],
    'Conversations': [
      'Introduce yourself to someone new at a networking event.',
      'Discuss a recent book or movie you enjoyed.',
      'Explain your hobby to someone unfamiliar with it.',
    ],
    'Debates': [
      'Argue for or against remote work being the future.',
      'Defend the position that AI will create more jobs than it replaces.',
      'Make the case for a 4-day work week.',
    ],
    'Storytelling': [
      'Share a personal story about a time you learned something unexpected.',
      'Tell a story about your most memorable travel experience.',
      'Narrate a story about overcoming a fear.',
    ],
  };

  static const _categoryTips = {
    'Presentations': [
      'Start with a hook to grab attention',
      'Keep your key message clear and concise',
      'Use pauses for emphasis',
    ],
    'Interviews': [
      'Use the STAR method (Situation, Task, Action, Result)',
      'Be specific with examples',
      'Show enthusiasm and confidence',
    ],
    'Public Speaking': [
      'Project your voice clearly',
      'Make eye contact with the audience',
      'Vary your tone to keep engagement',
    ],
    'Conversations': [
      'Be natural and authentic',
      'Listen as much as you speak',
      'Ask follow-up questions',
    ],
    'Debates': [
      'Structure your argument logically',
      'Anticipate counterarguments',
      'Stay calm and respectful',
    ],
    'Storytelling': [
      'Set the scene vividly',
      'Build tension before the climax',
      'End with a clear takeaway',
    ],
  };

  String get _prompt {
    if (challengePrompt != null) return challengePrompt!;
    final prompts = _categoryPrompts[category] ?? _categoryPrompts['Presentations']!;
    prompts.shuffle();
    return prompts.first;
  }

  List<String> get _tips {
    return _categoryTips[category] ?? _categoryTips['Presentations']!;
  }

  IconData get _categoryIcon {
    return switch (category) {
      'Presentations' => Icons.slideshow_rounded,
      'Interviews' => Icons.work_outline_rounded,
      'Public Speaking' => Icons.campaign_rounded,
      'Conversations' => Icons.chat_bubble_outline_rounded,
      'Debates' => Icons.forum_rounded,
      'Storytelling' => Icons.auto_stories_rounded,
      _ => Icons.mic_rounded,
    };
  }

  Color get _categoryColor {
    return switch (category) {
      'Presentations' => AppColors.categoryPresentations,
      'Interviews' => AppColors.categoryInterviews,
      'Public Speaking' => AppColors.categoryPublicSpeaking,
      'Conversations' => AppColors.categoryConversations,
      'Debates' => AppColors.categoryDebates,
      'Storytelling' => AppColors.categoryStorytelling,
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = _prompt;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _categoryColor.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _categoryIcon,
                    color: _categoryColor,
                    size: 40,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 24),

              // Prompt card
              Text('Your Prompt', style: AppTypography.titleLarge()),
              const SizedBox(height: 8),
              AppCard(
                gradient: AppColors.primaryGradient,
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Text(
                  prompt,
                  style: AppTypography.bodyLarge(color: AppColors.white),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Tips
              Text('Tips', style: AppTypography.titleLarge()),
              const SizedBox(height: 8),
              ..._tips.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(
                          color: _categoryColor.withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: AppTypography.bodyMedium(
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 300 + entry.key * 100),
                      duration: 400.ms,
                    ),
              ),

              const Spacer(),

              // Start button
              AppButton(
                label: 'Start Recording',
                icon: Icons.mic_rounded,
                onPressed: () {
                  context.push(
                    '/session/record',
                    extra: {
                      'category': category,
                      'prompt': prompt,
                    },
                  );
                },
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
