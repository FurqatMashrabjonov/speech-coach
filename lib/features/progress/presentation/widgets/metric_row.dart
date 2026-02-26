import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';

class MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final String valueText;
  final Color valueColor;

  const MetricRow({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.valueText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: valueColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleMedium()),
                Text(
                  description,
                  style: AppTypography.labelSmall(
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            valueText,
            style: AppTypography.titleMedium(color: valueColor)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
