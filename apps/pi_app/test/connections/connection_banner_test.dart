import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/bloc/connection_bloc.dart';
import 'package:pi_app/features/connections/widgets/connection_banner.dart';

class _MockConnectionBloc
    extends MockBloc<ConnectionEvent, ConnectionState>
    implements ConnectionBloc {}

Widget _wrap(ConnectionBloc bloc) {
  return MaterialApp(
    home: BlocProvider<ConnectionBloc>.value(
      value: bloc,
      child: const Scaffold(body: ConnectionBanner()),
    ),
  );
}

void main() {
  group('ConnectionBanner', () {
    late _MockConnectionBloc bloc;

    setUp(() => bloc = _MockConnectionBloc());
    tearDown(() => bloc.close());

    testWidgets(
      'shows nothing when ConnectionConnected',
      (tester) async {
        whenListen(
          bloc,
          Stream<ConnectionState>.value(const ConnectionConnected()),
          initialState: const ConnectionConnected(),
        );
        await tester.pumpWidget(_wrap(bloc));
        expect(find.text('Waiting for phone...'), findsNothing);
        expect(find.text('Connection error — restarting'), findsNothing);
      },
    );

    testWidgets(
      'shows waiting text when ConnectionWaiting',
      (tester) async {
        whenListen(
          bloc,
          Stream<ConnectionState>.value(const ConnectionWaiting()),
          initialState: const ConnectionWaiting(),
        );
        await tester.pumpWidget(_wrap(bloc));
        expect(find.text('Waiting for phone...'), findsOneWidget);
      },
    );

    testWidgets(
      'shows error text when ConnectionError',
      (tester) async {
        whenListen(
          bloc,
          Stream<ConnectionState>.value(const ConnectionError()),
          initialState: const ConnectionError(),
        );
        await tester.pumpWidget(_wrap(bloc));
        expect(find.text('Connection error — restarting'), findsOneWidget);
      },
    );
  });
}
