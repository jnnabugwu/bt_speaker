import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/connections/data/ws_event.dart';

void main() {
  group('WebSocketServer', () {
    late WebSocketServer server;

    setUp(() {
      // port 0 = OS assigns a free port, avoiding conflicts when tests run
      // concurrently across files
      server = WebSocketServer(port: 0);
    });

    tearDown(() async {
      await server.stop();
    });

    test('emits waiting then connected when a client connects', () async {
      final states = <ConnectionStatus>[];
      server.connectionStatus.listen(states.add);

      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(states, [ConnectionStatus.waiting, ConnectionStatus.connected]);

      await client.close();
    });

    test('emits waiting again after client disconnects', () async {
      final states = <ConnectionStatus>[];
      server.connectionStatus.listen(states.add);

      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await client.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        states,
        [
          ConnectionStatus.waiting,
          ConnectionStatus.connected,
          ConnectionStatus.waiting,
        ],
      );
    });

    test('emits BeatEvent for a beat message', () async {
      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final eventFuture = server.events.first;

      client.add(
        jsonEncode({
          'type': kBeatEvent,
          'bpm': 128,
          'intensity': 0.87,
          'fft_bars': List<double>.filled(16, 0.5),
        }),
      );

      final event = await eventFuture;
      expect(event, isA<BeatEvent>());
      final beat = (event as BeatEvent).data;
      expect(beat.bpm, 128);
      expect(beat.intensity, 0.87);

      await client.close();
    });

    test('emits LedEvent for a led message', () async {
      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final eventFuture = server.events.first;

      client.add(
        jsonEncode({
          'type': kLedEvent,
          'mode': 'beat_sync',
          'r': 255,
          'g': 0,
          'b': 128,
          'brightness': 200,
        }),
      );

      final event = await eventFuture;
      expect(event, isA<LedEvent>());
      expect((event as LedEvent).data.mode, LedMode.beatSync);

      await client.close();
    });

    test('emits EqEvent for an eq message', () async {
      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final eventFuture = server.events.first;

      client.add(
        jsonEncode({'type': kEqEvent, 'bass': 75, 'mid': 50, 'treble': 60}),
      );

      final event = await eventFuture;
      expect(event, isA<EqEvent>());
      final eq = (event as EqEvent).data;
      expect(eq.bass, 75);

      await client.close();
    });

    test('emits NowPlayingEvent for a now_playing message', () async {
      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final eventFuture = server.events.first;

      client.add(
        jsonEncode({
          'type': kNowPlaying,
          'title': 'Blinding Lights',
          'artist': 'The Weeknd',
          'album': 'After Hours',
          'progress_ms': 45000,
          'duration_ms': 200000,
        }),
      );

      final event = await eventFuture;
      expect(event, isA<NowPlayingEvent>());
      expect((event as NowPlayingEvent).data.title, 'Blinding Lights');

      await client.close();
    });

    test('ignores malformed JSON without crashing', () async {
      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final client =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      client.add('not valid json {{{{');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // server is still alive — a valid message after the bad one still works
      final eventFuture = server.events.first;
      client.add(
        jsonEncode({
          'type': kEqEvent,
          'bass': 10,
          'mid': 20,
          'treble': 30,
        }),
      );

      final event = await eventFuture;
      expect(event, isA<EqEvent>());

      await client.close();
    });

    test('rejects a second client with 503 while one is active', () async {
      unawaited(server.start());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final first =
          await WebSocket.connect('ws://localhost:${server.boundPort}');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // second connection attempt should fail with a non-101 response
      Object? error;
      try {
        await WebSocket.connect('ws://localhost:${server.boundPort}');
      } catch (e) {
        error = e;
      }
      expect(error, isNotNull);

      await first.close();
    });
  });
}
