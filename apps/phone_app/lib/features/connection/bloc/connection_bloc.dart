import 'dart:async';

import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connection_event.dart';
part 'connection_state.dart';

/// Manages the lifecycle of the WebSocket connection to the Pi.
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  /// Creates a [ConnectionBloc] that uses [clientFactory] to build a
  /// [WebSocketClient] for each new host.
  ConnectionBloc({
    required WebSocketClient Function(String host) clientFactory,
  })  : _clientFactory = clientFactory,
        super(const ConnectionIdle()) {
    on<ConnectionConnectRequested>(_onConnectRequested);
    on<ConnectionDisconnectRequested>(_onDisconnectRequested);
    on<ConnectionStatusUpdated>(_onStatusUpdated);
  }

  final WebSocketClient Function(String host) _clientFactory;
  WebSocketClient? _client;
  StreamSubscription<WebSocketClientStatus>? _statusSub;

  /// The currently active client, available after a successful connection.
  WebSocketClient? get activeClient => _client;

  Future<void> _onConnectRequested(
    ConnectionConnectRequested event,
    Emitter<ConnectionState> emit,
  ) async {
    await _statusSub?.cancel();
    await _client?.disconnect();
    await _client?.dispose();

    _client = _clientFactory(event.host);
    _statusSub = _client!.status.listen(
      (s) => add(ConnectionStatusUpdated(s)),
    );
    unawaited(_client!.connect());
  }

  Future<void> _onDisconnectRequested(
    ConnectionDisconnectRequested event,
    Emitter<ConnectionState> emit,
  ) async {
    await _statusSub?.cancel();
    _statusSub = null;
    await _client?.disconnect();
    emit(const ConnectionIdle());
  }

  void _onStatusUpdated(
    ConnectionStatusUpdated event,
    Emitter<ConnectionState> emit,
  ) {
    switch (event.status) {
      case WebSocketClientStatus.connecting:
        emit(const ConnectionConnecting());
      case WebSocketClientStatus.connected:
        emit(const ConnectionConnected());
      case WebSocketClientStatus.disconnected:
        emit(const ConnectionIdle());
      case WebSocketClientStatus.error:
        emit(const ConnectionFailed('Connection failed'));
    }
  }

  @override
  Future<void> close() async {
    await _statusSub?.cancel();
    await _client?.disconnect();
    await _client?.dispose();
    return super.close();
  }
}
