part of 'connection_bloc.dart';

///All events the [ConnectionBloc] can receive
sealed class ConnectionEvent {}

///Starts the WebSocket server and begins listening for a phone client
final class ConnectionStarted extends ConnectionEvent {}

///Stops the WebSocket server and resets to waiting state
final class ConnectionStopped extends ConnectionEvent {}

///Internal — fired from the connectionStatus stream; do not add externally
final class ConnectionStatusChanged extends ConnectionEvent {
  ///Creates a [ConnectionStatusChanged] with the given [status]
  ConnectionStatusChanged(this.status);

  ///The new connection status
  final ConnectionStatus status;
}
