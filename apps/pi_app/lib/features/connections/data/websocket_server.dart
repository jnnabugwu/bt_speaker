import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bt_speaker_core/bt_speaker_core.dart';

import 'package:pi_app/features/connections/data/ws_event.dart';

///Manages the WebSocket server on the Pi side.
///
///Listens on port 8080, accepts one phone client at a time, parses incoming
///JSON into typed [WsEvent]s, and exposes [connectionStatus] and [events]
///streams for BLoCs to consume.
class WebSocketServer {
  HttpServer? _httpServer;
  WebSocket? _client;

  final _status = StreamController<ConnectionStatus>.broadcast();
  final _events = StreamController<WsEvent>.broadcast();

  ///Emits the current [ConnectionStatus] whenever it changes
  Stream<ConnectionStatus> get connectionStatus => _status.stream;

  ///Emits a [WsEvent] for every valid message received from the phone
  Stream<WsEvent> get events => _events.stream;

  ///Binds to port 8080 and begins accepting connections.
  ///
  ///Only one client is accepted at a time. A second upgrade request while a
  ///client is active receives HTTP 503 and is closed immediately.
  Future<void> start() async {
    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    _status.add(ConnectionStatus.waiting);

    await for (final request in _httpServer!) {
      if (!WebSocketTransformer.isUpgradeRequest(request)) continue;

      if (_client != null) {
        request.response.statusCode = HttpStatus.serviceUnavailable;
        await request.response.close();
        continue;
      }

      _handleClient(await WebSocketTransformer.upgrade(request));
    }
  }

  ///Closes the active client connection and the HTTP server.
  Future<void> stop() async {
    await _client?.close();
    await _httpServer?.close(force: true);
    await _status.close();
    await _events.close();
  }

  void _handleClient(WebSocket socket) {
    _client = socket;
    _status.add(ConnectionStatus.connected);

    socket.listen(
      _parseMessage,
      onDone: _onDisconnect,
      onError: (_) => _onDisconnect(),
      cancelOnError: true,
    );
  }

  void _onDisconnect() {
    _client = null;
    _status.add(ConnectionStatus.waiting);
  }

  void _parseMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = switch (json['type'] as String) {
        kBeatEvent => BeatEvent(BeatData.fromJson(json)),
        kLedEvent => LedEvent(LedCommand.fromJson(json)),
        kEqEvent => EqEvent(EqSettings.fromJson(json)),
        kNowPlaying => NowPlayingEvent(NowPlaying.fromJson(json)),
        _ => null,
      };
      if (event != null) _events.add(event);
    } catch (_) {
      // malformed or unknown message — ignore without crashing the listener
    }
  }
}
