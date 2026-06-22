import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/visualizer/bloc/visualizer_bloc.dart';
import 'package:pi_app/features/visualizer/widgets/visualizer_canvas.dart';
import 'package:pi_app/features/visualizer/widgets/visualizer_painter.dart';

class _MockVisualizerBloc
    extends MockBloc<VisualizerEvent, VisualizerState>
    implements VisualizerBloc {}

Widget _wrap(VisualizerBloc bloc) {
  return MaterialApp(
    home: BlocProvider<VisualizerBloc>.value(
      value: bloc,
      child: const Scaffold(body: VisualizerCanvas()),
    ),
  );
}

void main() {
  group('VisualizerCanvas', () {
    late _MockVisualizerBloc bloc;

    setUp(() => bloc = _MockVisualizerBloc());
    tearDown(() => bloc.close());

    testWidgets(
      'renders CustomPaint with VisualizerPainter when VisualizerIdle',
      (tester) async {
        whenListen(
          bloc,
          Stream<VisualizerState>.value(const VisualizerIdle()),
          initialState: const VisualizerIdle(),
        );
        await tester.pumpWidget(_wrap(bloc));
        expect(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is VisualizerPainter,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders CustomPaint with VisualizerPainter when VisualizerActive',
      (tester) async {
        const state = VisualizerActive(
          BeatData(bpm: 120, intensity: 0.8, fftBars: [0.5, 0.9]),
        );
        whenListen(
          bloc,
          Stream<VisualizerState>.value(state),
          initialState: state,
        );
        await tester.pumpWidget(_wrap(bloc));
        expect(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is VisualizerPainter,
          ),
          findsOneWidget,
        );
      },
    );
  });
}
