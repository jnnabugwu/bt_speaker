import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/eq/bloc/eq_bloc.dart';
import 'package:bt_speaker/features/eq/widgets/eq_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockEqBloc extends MockBloc<EqEvent, EqState> implements EqBloc {}

void main() {
  group('EqScreen', () {
    late _MockEqBloc bloc;

    setUp(() {
      bloc = _MockEqBloc();
      whenListen(
        bloc,
        const Stream<EqState>.empty(),
        initialState: const EqCurrent(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('renders three sliders and labels', (tester) async {
      await tester.pumpWidget(
        BlocProvider<EqBloc>.value(
          value: bloc,
          child: const MaterialApp(home: Scaffold(body: EqScreen())),
        ),
      );

      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Mid'), findsOneWidget);
      expect(find.text('Treble'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(3));
    });
  });
}
