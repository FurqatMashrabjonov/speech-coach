import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';

class Scenario {
  final String id;
  final String category;
  final String title;
  final String description;
  final int durationMinutes;
  final String systemPrompt;
  final String difficulty;
  final IconData icon;

  const Scenario({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.systemPrompt,
    this.difficulty = 'Medium',
    this.icon = Icons.mic_rounded,
  });

  Duration get duration => Duration(minutes: durationMinutes);

  Color get categoryColor {
    switch (category) {
      case 'Interviews':
        return AppColors.categoryInterviews;
      case 'Presentations':
        return AppColors.categoryPresentations;
      case 'Public Speaking':
        return AppColors.categoryPublicSpeaking;
      case 'Conversations':
        return AppColors.categoryConversations;
      case 'Debates':
        return AppColors.categoryDebates;
      case 'Storytelling':
        return AppColors.categoryStorytelling;
      default:
        return AppColors.primary;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'Interviews':
        return Icons.work_outline_rounded;
      case 'Presentations':
        return Icons.slideshow_rounded;
      case 'Public Speaking':
        return Icons.campaign_rounded;
      case 'Conversations':
        return Icons.chat_bubble_outline_rounded;
      case 'Debates':
        return Icons.forum_rounded;
      case 'Storytelling':
        return Icons.auto_stories_rounded;
      default:
        return Icons.mic_rounded;
    }
  }
}
