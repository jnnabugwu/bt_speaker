part of 'connection_bloc.dart';

///All states the [ConnectionBloc] can emit
sealed class ConnectionState extends Equatable {
  const ConnectionState();
}

///Server is running but no phone client is connected
final class ConnectionWaiting extends ConnectionState {
  ///Creates a [ConnectionWaiting] state
  const ConnectionWaiting();

  @override
  List<Object?> get props => [];
}

///A phone client is connected and sending data
final class ConnectionConnected extends ConnectionState {
  ///Creates a [ConnectionConnected] state
  const ConnectionConnected();

  @override
  List<Object?> get props => [];
}

///The server encountered an error
final class ConnectionError extends ConnectionState {
  ///Creates a [ConnectionError] state
  const ConnectionError();

  @override
  List<Object?> get props => [];
}
