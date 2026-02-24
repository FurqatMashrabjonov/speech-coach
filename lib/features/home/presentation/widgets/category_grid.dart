import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_coach/app/constants/app_constants.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static const _categoryData = [
    _CategoryItem(
      name: 'Presentations',
      icon: Icons.slideshow_rounded,
      color: AppColors.categoryPresentations,
    ),
    _CategoryItem(
      name: 'Interviews',
      icon: Icons.work_outline_rounded,
      color: AppColors.categoryInterviews,
    ),
    _CategoryItem(
      name: 'Public Speaking',
      icon: Icons.campaign_rounded,
      color: AppColors.categoryPublicSpeaking,
    ),
    _CategoryItem(
      name: 'Conversations',
      icon: Icons.chat_bubble_outline_rounded,
      color: AppColors.categoryConversations,
    ),
    _CategoryItem(
      name: 'Debates',
      icon: Icons.forum_rounded,
      color: AppColors.categoryDebates,
    ),
    _CategoryItem(
      name: 'Storytelling',
      icon: Icons.auto_stories_rounded,
      color: AppColors.categoryStorytelling,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Practice Categories',
          style: AppTypography.headlineSmall(),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: AppConstants.categories.length,
          itemBuilder: (context, index) {
            final item = _categoryData[index];
            return _CategoryCard(item: item)
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  duration: 400.ms,
                )
                .slideY(begin: 0.1);
          },
        ),
      ],
    );
  }
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => _showModeSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  item.icon,
                  color: item.color,
                  size: 28,
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            Text(
              item.name,
              style: AppTypography.titleMedium(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showModeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).padding.bottom + 20,
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
            const SizedBox(height: 20),
            Text(
              'Choose Practice Mode',
              style: AppTypography.headlineSmall(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ModeOption(
                    icon: Icons.mic_rounded,
                    label: 'Record\n& Analyze',
                    color: item.color,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(
                        '/session/setup/${Uri.encodeComponent(item.name)}',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeOption(
                    icon: Icons.chat_rounded,
                    label: 'Chat\nwith AI',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(
                        '/conversation/${Uri.encodeComponent(item.name)}',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.labelMedium(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
