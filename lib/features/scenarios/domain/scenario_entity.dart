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
      case 'Phone Anxiety':
        return AppColors.categoryPhoneAnxiety;
      case 'Dating & Social':
        return AppColors.categoryDating;
      case 'Conflict & Boundaries':
        return AppColors.categoryConflict;
      case 'Social Situations':
        return AppColors.categorySocial;
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
      case 'Phone Anxiety':
        return Icons.phone_in_talk_rounded;
      case 'Dating & Social':
        return Icons.favorite_outline_rounded;
      case 'Conflict & Boundaries':
        return Icons.shield_outlined;
      case 'Social Situations':
        return Icons.groups_rounded;
      default:
        return Icons.mic_rounded;
    }
  }
}
