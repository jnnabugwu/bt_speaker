part of 'connection_bloc.dart';

/// Base class for all connection states.
sealed class ConnectionState extends Equatable {
  const ConnectionState();
}

/// Initial state — no connection has been attempted.
final class ConnectionIdle extends ConnectionState {
  /// Creates the idle state.
  const ConnectionIdle();

  @override
  List<Object?> get props => [];
}

/// The client is currently opening the WebSocket connection.
final class ConnectionConnecting extends ConnectionState {
  /// Creates the connecting state.
  const ConnectionConnecting();

  @override
  List<Object?> get props => [];
}

/// The WebSocket connection is open and ready.
final class ConnectionConnected extends ConnectionState {
  /// Creates the connected state.
  const ConnectionConnected();

  @override
  List<Object?> get props => [];
}

/// The connection attempt failed or the socket dropped unexpectedly.
final class ConnectionFailed extends ConnectionState {
  /// Creates a failed state with a human-readable [message].
  const ConnectionFailed(this.message);

  /// Describes why the connection failed.
  final String message;

  @override
  List<Object?> get props => [message];
}
