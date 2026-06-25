import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker_core/eq_settings.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'eq_event.dart';
part 'eq_state.dart';

/// Manages EQ band state and forwards changes to the Pi over WebSocket.
class EqBloc extends Bloc<EqEvent, EqState> {
  /// Creates an [EqBloc] that sends updates through [client].
  EqBloc({required WebSocketClient client})
    : _client = client,
      super(const EqCurrent()) {
    on<EqSettingsChanged>(_onSettingsChanged);
  }

  final WebSocketClient _client;

  void _onSettingsChanged(EqSettingsChanged event, Emitter<EqState> emit) {
    emit(EqCurrent(bass: event.bass, mid: event.mid, treble: event.treble));
    _client.send(
      EqSettings(
        bass: event.bass,
        mid: event.mid,
        treble: event.treble,
      ).toJson(),
    );
  }
}
