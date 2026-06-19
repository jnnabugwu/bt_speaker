import 'dart:async';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/connections/data/ws_event.dart' as ws;

part 'package:pi_app/features/led/bloc/led_event.dart';
part 'package:pi_app/features/led/bloc/led_state.dart';

///Listens to the WebSocket events stream and exposes the latest [LedCommand]
class LedBloc extends Bloc<LedEvent, LedState> {
  ///Creates a [LedBloc] with the given [WebSocketServer]
  LedBloc({required WebSocketServer server})
    : _server = server,
      super(const LedIdle()) {
    on<LedStarted>(_onStarted);
    on<LedStopped>(_onStopped);
    on<LedCommandReceived>(_onCommandReceived);
  }

  final WebSocketServer _server;
  StreamSubscription<ws.WsEvent>? _eventsSub;

  void _onStarted(LedStarted event, Emitter<LedState> emit) {
    _eventsSub = _server.events.listen((wsEvent) {
      if (wsEvent is ws.LedEvent) add(LedCommandReceived(wsEvent.data));
    });
  }

  void _onCommandReceived(LedCommandReceived event, Emitter<LedState> emit) {
    emit(LedActive(event.command));
  }

  Future<void> _onStopped(LedStopped event, Emitter<LedState> emit) async {
    await _eventsSub?.cancel();
    emit(const LedIdle());
  }

  @override
  Future<void> close() async {
    await _eventsSub?.cancel();
    return super.close();
  }
}
