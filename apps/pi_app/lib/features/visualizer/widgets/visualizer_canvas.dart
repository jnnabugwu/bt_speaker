import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/visualizer/bloc/visualizer_bloc.dart';
import 'package:pi_app/features/visualizer/widgets/visualizer_painter.dart';

/// Renders the live FFT visualizer using [VisualizerBloc] state.
///
/// Rebuilds on every [VisualizerState] emission and delegates all
/// drawing to [VisualizerPainter]. Shows a black canvas while idle.
class VisualizerCanvas extends StatelessWidget {
  /// Creates a [VisualizerCanvas].
  const VisualizerCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisualizerBloc, VisualizerState>(
      builder: (context, state) {
        final bars = state is VisualizerActive
            ? state.data.fftBars
            : const <double>[];
        final intensity =
            state is VisualizerActive ? state.data.intensity : 0.0;

        return CustomPaint(
          painter: VisualizerPainter(fftBars: bars, intensity: intensity),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
