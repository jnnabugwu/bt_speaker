import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/led/bloc/led_bloc.dart';

void main() {
  group('LedBloc', () {
    late WebSocketServer server;
    late LedBloc bloc;

    setUp(() {
      server = WebSocketServer(port: 0);
      bloc = LedBloc(server: server);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is LedIdle', () {
      expect(bloc.state, isA<LedIdle>());
    });

    blocTest<LedBloc, LedState>(
      'emits LedActive when a LedEvent is received',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => LedBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(LedStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({
            'type': 'led',
            'mode': 'beat_sync',
            'r': 255,
            'g': 0,
            'b': 128,
            'brightness': 200,
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<LedActive>()],
    );

    blocTest<LedBloc, LedState>(
      'emits LedIdle after LedStopped',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => LedBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(LedStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({
            'type': 'led',
            'mode': 'static',
            'r': 100,
            'g': 200,
            'b': 50,
            'brightness': 150,
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(LedStopped());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<LedActive>(), isA<LedIdle>()],
    );

    blocTest<LedBloc, LedState>(
      'close() shuts down without error',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => LedBloc(server: server),
      act: (bloc) async {
        bloc.add(LedStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => <LedState>[],
    );
  });
}
