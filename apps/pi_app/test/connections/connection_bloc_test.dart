import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/bloc/connection_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';

void main() {
  group('ConnectionBloc', () {
    late WebSocketServer server;
    late ConnectionBloc bloc;

    setUp(() {
      server = WebSocketServer(port: 0);
      bloc = ConnectionBloc(server: server);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is ConnectionWaiting', () {
      expect(bloc.state, isA<ConnectionWaiting>());
    });

    blocTest<ConnectionBloc, ConnectionState>(
      'emits [Waiting, Connected, Waiting] for connect then disconnect',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => ConnectionBloc(server: server),
      act: (bloc) async {
        bloc.add(ConnectionStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [
        isA<ConnectionWaiting>(),
        isA<ConnectionConnected>(),
        isA<ConnectionWaiting>(),
      ],
    );

    blocTest<ConnectionBloc, ConnectionState>(
      'emits [Waiting, Connected, Waiting] after ConnectionStopped',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => ConnectionBloc(server: server),
      act: (bloc) async {
        bloc.add(ConnectionStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await WebSocket.connect('ws://localhost:${server.boundPort}');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(ConnectionStopped());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [
        isA<ConnectionWaiting>(),
        isA<ConnectionConnected>(),
        isA<ConnectionWaiting>(),
      ],
    );

    blocTest<ConnectionBloc, ConnectionState>(
      'close() shuts down the server without error',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => ConnectionBloc(server: server),
      act: (bloc) async {
        bloc.add(ConnectionStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [isA<ConnectionWaiting>()],
    );
  });
}
