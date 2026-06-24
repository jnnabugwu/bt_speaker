import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/led/bloc/led_bloc.dart';
import 'package:bt_speaker/features/led/widgets/led_screen.dart';
import 'package:bt_speaker_core/led_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockLedBloc extends MockBloc<LedEvent, LedState> implements LedBloc {}

void main() {
  group('LedScreen', () {
    late _MockLedBloc bloc;

    setUp(() {
      bloc = _MockLedBloc();
      whenListen(
        bloc,
        const Stream<LedState>.empty(),
        initialState: const LedCurrent(),
      );
    });

    tearDown(() => bloc.close());

    testWidgets('renders four sliders and a mode dropdown', (tester) async {
      await tester.pumpWidget(
        BlocProvider<LedBloc>.value(
          value: bloc,
          child: const MaterialApp(home: Scaffold(body: LedScreen())),
        ),
      );

      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Brightness'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(4));
      expect(find.byType(DropdownButton<LedMode>), findsOneWidget);
    });
  });
}
