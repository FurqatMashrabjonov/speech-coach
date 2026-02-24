import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.backgroundColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
          child: Ink(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null
                  ? (backgroundColor ?? Theme.of(context).cardTheme.color)
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: isDark ? AppShadows.cardDark : AppShadows.subtle,
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? (backgroundColor ?? Theme.of(context).cardTheme.color)
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.subtle,
      ),
      child: child,
    );
  }
}
