import 'dart:async';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/connections/data/ws_event.dart' as ws;

part 'package:pi_app/features/now_playing/bloc/now_playing_event.dart';
part 'package:pi_app/features/now_playing/bloc/now_playing_state.dart';

///Listens to the WebSocket events stream and exposes the latest [NowPlaying]
class NowPlayingBloc extends Bloc<NowPlayingEvent, NowPlayingState> {
  ///Creates a [NowPlayingBloc] with the given [WebSocketServer]
  NowPlayingBloc({required WebSocketServer server})
    : _server = server,
      super(const NowPlayingIdle()) {
    on<NowPlayingStarted>(_onStarted);
    on<NowPlayingStopped>(_onStopped);
    on<NowPlayingTrackReceived>(_onTrackReceived);
  }

  final WebSocketServer _server;
  StreamSubscription<ws.WsEvent>? _eventsSub;

  void _onStarted(NowPlayingStarted event, Emitter<NowPlayingState> emit) {
    _eventsSub = _server.events.listen((wsEvent) {
      if (wsEvent is ws.NowPlayingEvent) {
        add(NowPlayingTrackReceived(wsEvent.data));
      }
    });
  }

  void _onTrackReceived(
    NowPlayingTrackReceived event,
    Emitter<NowPlayingState> emit,
  ) {
    emit(NowPlayingActive(event.track));
  }

  Future<void> _onStopped(
    NowPlayingStopped event,
    Emitter<NowPlayingState> emit,
  ) async {
    await _eventsSub?.cancel();
    emit(const NowPlayingIdle());
  }

  @override
  Future<void> close() async {
    await _eventsSub?.cancel();
    return super.close();
  }
}
