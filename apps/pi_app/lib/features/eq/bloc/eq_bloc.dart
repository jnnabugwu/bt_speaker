import 'dart:async';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/connections/data/ws_event.dart' as ws;

part 'package:pi_app/features/eq/bloc/eq_event.dart';
part 'package:pi_app/features/eq/bloc/eq_state.dart';

///Listens to the WebSocket events stream and exposes the latest [EqSettings]
class EqBloc extends Bloc<EqEvent, EqState> {
  ///Creates an [EqBloc] with the given [WebSocketServer]
  EqBloc({required WebSocketServer server})
    : _server = server,
      super(const EqIdle()) {
    on<EqStarted>(_onStarted);
    on<EqStopped>(_onStopped);
    on<EqSettingsReceived>(_onSettingsReceived);
  }

  final WebSocketServer _server;
  StreamSubscription<ws.WsEvent>? _eventsSub;

  void _onStarted(EqStarted event, Emitter<EqState> emit) {
    _eventsSub = _server.events.listen((wsEvent) {
      if (wsEvent is ws.EqEvent) add(EqSettingsReceived(wsEvent.data));
    });
  }

  void _onSettingsReceived(EqSettingsReceived event, Emitter<EqState> emit) {
    emit(EqActive(event.settings));
  }

  Future<void> _onStopped(EqStopped event, Emitter<EqState> emit) async {
    await _eventsSub?.cancel();
    emit(const EqIdle());
  }

  @override
  Future<void> close() async {
    await _eventsSub?.cancel();
    return super.close();
  }
}
