import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Connection status reported by [WebSocketClient].
enum WebSocketClientStatus {
  /// No active connection.
  disconnected,

  /// Attempting to connect.
  connecting,

  /// Socket is open and ready.
  connected,

  /// Connection attempt or socket failed.
  error,
}

/// Thin WebSocket client that connects to the Pi server
/// and sends JSON messages.
class WebSocketClient {
  /// Creates a client targeting [host] on [port] (default 8080).
  WebSocketClient({required this.host, this.port = 8080});

  /// The hostname or IP address of the Pi.
  final String host;

  /// The port the Pi server listens on.
  final int port;

  WebSocket? _socket;
  bool _intentionalClose = false;
  final _statusController = StreamController<WebSocketClientStatus>.broadcast(
    sync: true,
  );

  /// Broadcast stream of connection status changes.
  Stream<WebSocketClientStatus> get status => _statusController.stream;

  /// Opens the WebSocket connection, emitting
  /// [WebSocketClientStatus.connecting] then
  /// [WebSocketClientStatus.connected] or [WebSocketClientStatus.error].
  Future<void> connect() async {
    _intentionalClose = false;
    _statusController.add(WebSocketClientStatus.connecting);
    try {
      _socket = await WebSocket.connect('ws://$host:$port');
      _statusController.add(WebSocketClientStatus.connected);
      _socket!.listen(
        null,
        onDone: () {
          if (!_intentionalClose) {
            _statusController.add(WebSocketClientStatus.disconnected);
          }
        },
        onError: (_) {
          _statusController.add(WebSocketClientStatus.error);
        },
        cancelOnError: true,
      );
    } catch (_) {
      _statusController.add(WebSocketClientStatus.error);
    }
  }

  /// Sends [json] as an encoded string over the socket.
  /// No-ops if the socket is not open.
  void send(Map<String, dynamic> json) {
    if (_socket == null || _socket!.readyState != WebSocket.open) {
      return;
    }
    _socket!.add(jsonEncode(json));
  }

  /// Closes the socket cleanly and emits [WebSocketClientStatus.disconnected].
  Future<void> disconnect() async {
    _intentionalClose = true;
    await _socket?.close();
    _socket = null;
    _statusController.add(WebSocketClientStatus.disconnected);
  }

  /// Closes the internal [StreamController]. Call after [disconnect].
  Future<void> dispose() async {
    await _statusController.close();
  }
}
