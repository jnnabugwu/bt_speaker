import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/connection/bloc/connection_bloc.dart';
import 'package:bt_speaker/features/connection/widgets/connection_screen.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectionBloc
    extends MockBloc<ConnectionEvent, ConnectionState>
    implements ConnectionBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(ConnectionDisconnectRequested());
  });

  group('ConnectionScreen', () {
    late _MockConnectionBloc bloc;

    setUp(() {
      bloc = _MockConnectionBloc();
      when(() => bloc.close()).thenAnswer((_) async {});
    });

    tearDown(() => bloc.close());

    Widget buildSubject() => BlocProvider<ConnectionBloc>.value(
          value: bloc,
          child: const MaterialApp(home: ConnectionScreen()),
        );

    testWidgets('shows Connect button in idle state', (tester) async {
      whenListen(
        bloc,
        const Stream<ConnectionState>.empty(),
        initialState: const ConnectionIdle(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Connect'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner while connecting', (tester) async {
      whenListen(
        bloc,
        const Stream<ConnectionState>.empty(),
        initialState: const ConnectionConnecting(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Connect'), findsNothing);
    });

    testWidgets('shows error message and Retry on failure', (tester) async {
      whenListen(
        bloc,
        const Stream<ConnectionState>.empty(),
        initialState: const ConnectionFailed('Connection failed'),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('dispatches connect event on button tap', (tester) async {
      whenListen(
        bloc,
        const Stream<ConnectionState>.empty(),
        initialState: const ConnectionIdle(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Connect'));
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<ConnectionConnectRequested>())),
      ).called(1);
    });
  });
}
