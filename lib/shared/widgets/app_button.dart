import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';
import 'package:speech_coach/core/extensions/context_extensions.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 54.0;

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: buttonHeight,
      child: switch (variant) {
        AppButtonVariant.primary => _buildPrimary(context),
        AppButtonVariant.secondary => _buildSecondary(context),
        AppButtonVariant.outline => _buildOutline(context),
        AppButtonVariant.text => _buildText(context),
      },
    );
  }

  Widget _buildPrimary(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null && !isLoading
            ? AppColors.primary
            : context.divider,
        foregroundColor: AppColors.white,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        disabledBackgroundColor: context.divider,
      ),
      child: _buildChild(AppColors.white),
    );
  }

  Widget _buildSecondary(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withValues(alpha: 0.14),
        foregroundColor: AppColors.primary,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildOutline(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildText(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(AppColors.primary),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.button(color: color)),
        ],
      );
    }

    return Text(label, style: AppTypography.button(color: color));
  }
}
