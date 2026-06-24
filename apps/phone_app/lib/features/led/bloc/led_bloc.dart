import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker_core/led_command.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'led_event.dart';
part 'led_state.dart';

/// Manages LED control state and forwards changes to the Pi over WebSocket.
class LedBloc extends Bloc<LedEvent, LedState> {
  /// Creates a [LedBloc] that sends updates through [client].
  LedBloc({required WebSocketClient client})
      : _client = client,
        super(const LedCurrent()) {
    on<LedCommandChanged>(_onCommandChanged);
  }

  final WebSocketClient _client;

  void _onCommandChanged(
    LedCommandChanged event,
    Emitter<LedState> emit,
  ) {
    emit(
      LedCurrent(
        mode: event.mode,
        r: event.r,
        g: event.g,
        b: event.b,
        brightness: event.brightness,
      ),
    );
    _client.send(
      LedCommand(
        mode: event.mode,
        r: event.r,
        g: event.g,
        b: event.b,
        brightness: event.brightness,
      ).toJson(),
    );
  }
}
