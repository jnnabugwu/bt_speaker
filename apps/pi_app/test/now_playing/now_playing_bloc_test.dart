import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/now_playing/bloc/now_playing_bloc.dart';

void main() {
  group('NowPlayingBloc', () {
    late WebSocketServer server;
    late NowPlayingBloc bloc;

    setUp(() {
      server = WebSocketServer(port: 0);
      bloc = NowPlayingBloc(server: server);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is NowPlayingIdle', () {
      expect(bloc.state, isA<NowPlayingIdle>());
    });

    blocTest<NowPlayingBloc, NowPlayingState>(
      'emits NowPlayingActive when a NowPlayingEvent is received',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => NowPlayingBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(NowPlayingStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({
            'type': 'now_playing',
            'title': 'Song',
            'artist': 'Artist',
            'album': 'Album',
            'progress_ms': 30000,
            'duration_ms': 240000,
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<NowPlayingActive>()],
    );

    blocTest<NowPlayingBloc, NowPlayingState>(
      'emits NowPlayingIdle after NowPlayingStopped',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => NowPlayingBloc(server: server),
      act: (bloc) async {
        unawaited(server.start());
        bloc.add(NowPlayingStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final client = await WebSocket.connect(
          'ws://localhost:${server.boundPort}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        client.add(
          jsonEncode({
            'type': 'now_playing',
            'title': 'Song',
            'artist': 'Artist',
            'album': 'Album',
            'progress_ms': 30000,
            'duration_ms': 240000,
          }),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(NowPlayingStopped());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await client.close();
      },
      expect: () => [isA<NowPlayingActive>(), isA<NowPlayingIdle>()],
    );

    blocTest<NowPlayingBloc, NowPlayingState>(
      'close() shuts down without error',
      setUp: () => server = WebSocketServer(port: 0),
      build: () => NowPlayingBloc(server: server),
      act: (bloc) async {
        bloc.add(NowPlayingStarted());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => <NowPlayingState>[],
    );
  });
}
