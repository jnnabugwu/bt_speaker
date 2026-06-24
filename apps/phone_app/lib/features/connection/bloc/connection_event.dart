part of 'connection_bloc.dart';

/// Base class for all connection events.
sealed class ConnectionEvent {}

/// Requests the BLoC to open a WebSocket connection to [host].
final class ConnectionConnectRequested extends ConnectionEvent {
  /// Creates a connect request for [host].
  ConnectionConnectRequested(this.host);

  /// The IP address or hostname to connect to.
  final String host;
}

/// Requests the BLoC to close the active connection.
final class ConnectionDisconnectRequested extends ConnectionEvent {}

/// Internal — emitted from the [WebSocketClient] status stream.
final class ConnectionStatusUpdated extends ConnectionEvent {
  /// Creates a status update carrying [status].
  ConnectionStatusUpdated(this.status);

  /// The new status from the underlying client.
  final WebSocketClientStatus status;
}
