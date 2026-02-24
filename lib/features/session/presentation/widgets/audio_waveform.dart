import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_coach/app/theme/app_colors.dart';

class AudioWaveform extends StatefulWidget {
  final double amplitude;
  final bool isActive;

  const AudioWaveform({
    super.key,
    required this.amplitude,
    this.isActive = true,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _WaveformPainter(
            amplitude: widget.isActive ? widget.amplitude : 0.05,
            phase: _controller.value * 2 * pi,
            color: AppColors.primary,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double amplitude;
  final double phase;
  final Color color;

  _WaveformPainter({
    required this.amplitude,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 40;
    final barWidth = size.width / (barCount * 2);
    final maxHeight = size.height * 0.8;
    final centerY = size.height / 2;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < barCount; i++) {
      final x = (i * 2 + 0.5) * barWidth;
      final wave = sin((i / barCount * 4 * pi) + phase);
      final height =
          (maxHeight * 0.15) + (maxHeight * 0.85 * amplitude * (0.5 + 0.5 * wave));
      final clampedHeight = height.clamp(4.0, maxHeight);

      final t = i / barCount;
      paint.color = Color.lerp(
        color,
        AppColors.secondary,
        t,
      )!.withValues(alpha: 0.6 + 0.4 * amplitude);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: barWidth * 0.8,
          height: clampedHeight,
        ),
        Radius.circular(barWidth),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude || oldDelegate.phase != phase;
  }
}
