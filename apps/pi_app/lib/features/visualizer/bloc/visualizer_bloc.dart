import 'dart:async';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/connections/data/ws_event.dart' as ws;

part 'package:pi_app/features/visualizer/bloc/visualizer_event.dart';
part 'package:pi_app/features/visualizer/bloc/visualizer_state.dart';

///Listens to the WebSocket events stream and exposes the latest [BeatData]
class VisualizerBloc extends Bloc<VisualizerEvent, VisualizerState> {
  ///Creates a [VisualizerBloc] with the given [WebSocketServer]
  VisualizerBloc({required WebSocketServer server})
    : _server = server,
      super(const VisualizerIdle()) {
    on<VisualizerStarted>(_onStarted);
    on<VisualizerStopped>(_onStopped);
    on<VisualizerBeatReceived>(_onBeatReceived);
  }

  final WebSocketServer _server;
  StreamSubscription<ws.WsEvent>? _eventsSub;

  void _onStarted(VisualizerStarted event, Emitter<VisualizerState> emit) {
    _eventsSub = _server.events.listen((wsEvent) {
      if (wsEvent is ws.BeatEvent) add(VisualizerBeatReceived(wsEvent.data));
    });
  }

  void _onBeatReceived(
    VisualizerBeatReceived event,
    Emitter<VisualizerState> emit,
  ) {
    emit(VisualizerActive(event.data));
  }

  Future<void> _onStopped(
    VisualizerStopped event,
    Emitter<VisualizerState> emit,
  ) async {
    await _eventsSub?.cancel();
    emit(const VisualizerIdle());
  }

  @override
  Future<void> close() async {
    await _eventsSub?.cancel();
    return super.close();
  }
}
