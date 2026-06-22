import 'package:flutter/material.dart';

/// Draws the FFT frequency-bar visualizer on a [Canvas].
///
/// Each element in [fftBars] maps to one vertical bar drawn bottom-up.
/// Bar opacity pulses with [intensity] to accent the beat.
class VisualizerPainter extends CustomPainter {
  /// Creates a [VisualizerPainter] with the given [fftBars] and [intensity].
  const VisualizerPainter({
    required this.fftBars,
    required this.intensity,
    this.barColor = Colors.cyanAccent,
    this.barGap = 2,
  });

  /// Normalised frequency magnitudes (0.0–1.0) rendered as vertical bars.
  final List<double> fftBars;

  /// Beat intensity (0.0–1.0); modulates bar opacity to pulse on the beat.
  final double intensity;

  /// Fill colour for each bar.
  final Color barColor;

  /// Horizontal gap between bars in logical pixels.
  final double barGap;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    if (fftBars.isEmpty) return;

    final count = fftBars.length;
    final totalGap = barGap * (count - 1);
    final barWidth =
        ((size.width - totalGap) / count).clamp(1.0, size.width);

    final paint = Paint()
      ..color = barColor.withValues(
        alpha: (0.6 + intensity * 0.4).clamp(0.0, 1.0),
      )
      ..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final magnitude = fftBars[i].clamp(0.0, 1.0);
      final barHeight = size.height * magnitude;
      final left = i * (barWidth + barGap);
      canvas.drawRect(
        Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(VisualizerPainter old) =>
      old.fftBars != fftBars || old.intensity != intensity;
}
