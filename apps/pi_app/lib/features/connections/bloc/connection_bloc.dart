import 'dart:async';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';

part 'package:pi_app/features/connections/bloc/connection_event.dart';
part 'package:pi_app/features/connections/bloc/connection_state.dart';


///Manages the WebSocket server lifecycle and exposes connection state to the UI
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  ///Creates a [ConnectionBloc] with the given [WebSocketServer]
  ConnectionBloc({required WebSocketServer server})
      : _server = server,
        super(const ConnectionWaiting()) {
    on<ConnectionStarted>(_onStarted);
    on<ConnectionStopped>(_onStopped);
    on<ConnectionStatusChanged>(_onStatusChanged);
  }

  final WebSocketServer _server;
  StreamSubscription<ConnectionStatus>? _statusSub;

  Future<void> _onStarted(
    ConnectionStarted event,
    Emitter<ConnectionState> emit,
  ) async {
    _statusSub = _server.connectionStatus.listen(
      (status) => add(ConnectionStatusChanged(status)),
    );
    // start() loops forever — fire without awaiting so the handler
    // returns and the BLoC can process subsequent events
    unawaited(_server.start());
  }

  void _onStatusChanged(
    ConnectionStatusChanged event,
    Emitter<ConnectionState> emit,
  ) {
    emit(switch (event.status) {
      ConnectionStatus.waiting => const ConnectionWaiting(),
      ConnectionStatus.connected => const ConnectionConnected(),
      ConnectionStatus.error => const ConnectionError(),
    });
  }

  Future<void> _onStopped(
    ConnectionStopped event,
    Emitter<ConnectionState> emit,
  ) async {
    await _statusSub?.cancel();
    await _server.stop();
    emit(const ConnectionWaiting());
  }

  @override
  Future<void> close() async {
    await _statusSub?.cancel();
    await _server.stop();
    return super.close();
  }
}
