import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/eq/bloc/eq_bloc.dart';

void main() {
  group('EqBloc', () {
    late WebSocketServer server;
    late EqBloc bloc;

    setUp(() {
      server = WebSocketServer(port: 0);
      bloc = EqBloc(server: server);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is EqIdle', () {
      expect(bloc.state, isA<EqIdle>());
    });

    blocTest<EqBloc, EqState>(
      'emits EqActive when an EqEvent is received',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => EqBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(EqStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({'type': 'eq', 'bass': 5, 'mid': 0, 'treble': -3}),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<EqActive>()],
    );

    blocTest<EqBloc, EqState>(
      'emits EqIdle after EqStopped',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => EqBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(EqStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({'type': 'eq', 'bass': 5, 'mid': 0, 'treble': -3}),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(EqStopped());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<EqActive>(), isA<EqIdle>()],
    );

    blocTest<EqBloc, EqState>(
      'close() shuts down without error',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => EqBloc(server: server),
      act: (bloc) async {
        bloc.add(EqStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => <EqState>[],
    );
  });
}
