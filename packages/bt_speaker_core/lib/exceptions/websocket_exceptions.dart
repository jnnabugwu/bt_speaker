///Exception thrown when a websocket exception occurs
class WebsocketException implements Exception {
  ///Creates a new websocket exception
  const WebsocketException({required this.message});

  ///The message of the exception
  final String message;

  @override
  String toString() => 'WebsocketException: $message';
}
