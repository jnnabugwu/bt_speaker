///The connection status of the websocket
enum ConnectionStatus {
  ///Waiting for a client to connect
  waiting,

  ///A client is connected
  connected,

  ///An error occurred
  error,
}
