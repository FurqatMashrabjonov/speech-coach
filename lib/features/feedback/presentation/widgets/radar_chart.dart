import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';
import 'package:speech_coach/app/theme/app_typography.dart';

class ScoreRadarChart extends StatelessWidget {
  final int clarity;
  final int confidence;
  final int engagement;
  final int relevance;
  final double size;

  const ScoreRadarChart({
    super.key,
    required this.clarity,
    required this.confidence,
    required this.engagement,
    required this.relevance,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(
          values: [
            clarity / 10,
            confidence / 10,
            engagement / 10,
            relevance / 10,
          ],
          labels: ['Clarity', 'Confidence', 'Engagement', 'Relevance'],
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _RadarPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 30;
    final sides = values.length;
    final angle = 2 * pi / sides;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.dividerLight
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var level = 1; level <= 5; level++) {
      final r = radius * level / 5;
      final path = Path();
      for (var i = 0; i < sides; i++) {
        final x = center.dx + r * cos(angle * i - pi / 2);
        final y = center.dy + r * sin(angle * i - pi / 2);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axes
    for (var i = 0; i < sides; i++) {
      final x = center.dx + radius * cos(angle * i - pi / 2);
      final y = center.dy + radius * sin(angle * i - pi / 2);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw value polygon
    final valuePath = Path();
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < sides; i++) {
      final r = radius * values[i];
      final x = center.dx + r * cos(angle * i - pi / 2);
      final y = center.dy + r * sin(angle * i - pi / 2);
      if (i == 0) {
        valuePath.moveTo(x, y);
      } else {
        valuePath.lineTo(x, y);
      }
    }
    valuePath.close();
    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (var i = 0; i < sides; i++) {
      final r = radius * values[i];
      final x = center.dx + r * cos(angle * i - pi / 2);
      final y = center.dy + r * sin(angle * i - pi / 2);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Draw labels
    for (var i = 0; i < sides; i++) {
      final labelRadius = radius + 20;
      final x = center.dx + labelRadius * cos(angle * i - pi / 2);
      final y = center.dy + labelRadius * sin(angle * i - pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: AppTypography.labelSmall(color: AppColors.textSecondaryLight),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
