import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/visualizer/widgets/visualizer_painter.dart';

void main() {
  group('VisualizerPainter', () {
    testWidgets('paint does not throw with empty fftBars', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: CustomPaint(
              painter: VisualizerPainter(fftBars: [], intensity: 0),
            ),
          ),
        ),
      );
    });

    testWidgets('paint does not throw with 32 bars at full intensity', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: CustomPaint(
              painter: VisualizerPainter(
                fftBars: List<double>.filled(32, 1),
                intensity: 1,
              ),
            ),
          ),
        ),
      );
    });

    test('shouldRepaint returns false for identical instance', () {
      const painter = VisualizerPainter(fftBars: [], intensity: 0);
      expect(painter.shouldRepaint(painter), isFalse);
    });

    test('shouldRepaint returns true for different list reference', () {
      const bars = <double>[0.5, 0.8];
      const p1 = VisualizerPainter(fftBars: bars, intensity: 0.5);
      // Use a non-const list so the reference differs from the const [bars].
      final differentBars = <double>[0.5, 0.8];
      final p2 = VisualizerPainter(fftBars: differentBars, intensity: 0.5);
      expect(p1.shouldRepaint(p2), isTrue);
    });

    test('shouldRepaint returns true when intensity changes', () {
      const bars = <double>[0.5];
      const p1 = VisualizerPainter(fftBars: bars, intensity: 0.2);
      const p2 = VisualizerPainter(fftBars: bars, intensity: 0.9);
      expect(p1.shouldRepaint(p2), isTrue);
    });
  });
}
