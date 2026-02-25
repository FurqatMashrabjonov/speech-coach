import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';
import 'package:speech_coach/features/roast/data/roast_service.dart';
import 'package:speech_coach/shared/widgets/tappable.dart';

class RoastIntensityPicker extends StatelessWidget {
  final void Function(RoastIntensity intensity) onSelected;

  const RoastIntensityPicker({super.key, required this.onSelected});

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
          const SizedBox(height: 20),
          Text('Roast Intensity', style: AppTypography.headlineSmall()),
          const SizedBox(height: 4),
          Text(
            'How spicy do you want it?',
            style: AppTypography.bodySmall(color: context.textSecondary),
          ),
          const SizedBox(height: 20),
          _IntensityOption(
            label: 'Gentle Nudge',
            description: 'Supportive teasing',
            flames: 1,
            onTap: () {
              Navigator.pop(context);
              onSelected(RoastIntensity.gentle);
            },
          ),
          const SizedBox(height: 10),
          _IntensityOption(
            label: 'Honest Friend',
            description: 'Real talk with humor',
            flames: 2,
            onTap: () {
              Navigator.pop(context);
              onSelected(RoastIntensity.honest);
            },
          ),
          const SizedBox(height: 10),
          _IntensityOption(
            label: 'Full Savage',
            description: 'Comedy roast mode',
            flames: 3,
            onTap: () {
              Navigator.pop(context);
              onSelected(RoastIntensity.savage);
            },
          ),
        ],
      ),
    );
  }
}

class _IntensityOption extends StatelessWidget {
  final String label;
  final String description;
  final int flames;
  final VoidCallback onTap;

  const _IntensityOption({
    required this.label,
    required this.description,
    required this.flames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06 + (flames * 0.04)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.1 + (flames * 0.05)),
          ),
        ),
        child: Row(
          children: [
            Text(
              List.generate(flames, (_) => '\u{1F525}').join(),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleMedium()),
                  Text(
                    description,
                    style: AppTypography.bodySmall(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
