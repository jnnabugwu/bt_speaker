import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/visualizer/bloc/visualizer_bloc.dart';

void main() {
  group('VisualizerBloc', () {
    late WebSocketServer server;
    late VisualizerBloc bloc;

    setUp(() {
      server = WebSocketServer(port: 0);
      bloc = VisualizerBloc(server: server);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is VisualizerIdle', () {
      expect(bloc.state, isA<VisualizerIdle>());
    });

    blocTest<VisualizerBloc, VisualizerState>(
      'emits VisualizerActive when a BeatEvent is received',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => VisualizerBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(VisualizerStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({
            'type': 'beat',
            'bpm': 120,
            'intensity': 0.8,
            'fft_bars': [0.1, 0.5, 0.9],
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<VisualizerActive>()],
    );

    blocTest<VisualizerBloc, VisualizerState>(
      'emits VisualizerIdle after VisualizerStopped',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => VisualizerBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(VisualizerStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({
            'type': 'beat',
            'bpm': 100,
            'intensity': 0.5,
            'fft_bars': [0.2, 0.4],
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(VisualizerStopped());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<VisualizerActive>(), isA<VisualizerIdle>()],
    );

    blocTest<VisualizerBloc, VisualizerState>(
      'close() shuts down without error',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => VisualizerBloc(server: server),
      act: (bloc) async {
        bloc.add(VisualizerStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => <VisualizerState>[],
    );
  });
}
