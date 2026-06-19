part of 'led_bloc.dart';

///All events the [LedBloc] can receive
sealed class LedEvent {}

///Starts listening to the WebSocket events stream for LED commands
final class LedStarted extends LedEvent {}

///Stops listening and resets to idle
final class LedStopped extends LedEvent {}

///Internal — fired from the events stream; do not add externally
final class LedCommandReceived extends LedEvent {
  ///Creates a [LedCommandReceived] with the given [command]
  LedCommandReceived(this.command);

  ///The LED command payload
  final LedCommand command;
}
