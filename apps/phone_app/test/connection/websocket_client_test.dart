import 'dart:io';

import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebSocketClient', () {
    late HttpServer server;
    late List<WebSocket> serverConnections;
    late WebSocketClient client;

    setUp(() async {
      serverConnections = [];
      server = await HttpServer.bind('127.0.0.1', 0)
        ..listen((request) async {
          if (WebSocketTransformer.isUpgradeRequest(request)) {
            final ws = await WebSocketTransformer.upgrade(request);
            serverConnections.add(ws);
          }
        });
      client = WebSocketClient(host: '127.0.0.1', port: server.port);
    });

    tearDown(() async {
      for (final ws in serverConnections) {
        await ws.close();
      }
      await client.disconnect();
      await client.dispose();
      await server.close(force: true);
    });

    test('emits connecting then connected on successful connect', () async {
      final statuses = <WebSocketClientStatus>[];
      final sub = client.status.listen(statuses.add);

      await client.connect();

      expect(
        statuses,
        containsAllInOrder([
          WebSocketClientStatus.connecting,
          WebSocketClientStatus.connected,
        ]),
      );

      await sub.cancel();
    });

    test('emits error when connection is refused', () async {
      // Grab a free port, close it immediately → connection refused.
      final tempServer = await HttpServer.bind('127.0.0.1', 0);
      final port = tempServer.port;
      await tempServer.close(force: true);

      final badClient = WebSocketClient(host: '127.0.0.1', port: port);
      final statuses = <WebSocketClientStatus>[];
      final sub = badClient.status.listen(statuses.add);

      await badClient.connect();

      expect(statuses, contains(WebSocketClientStatus.error));

      await sub.cancel();
      await badClient.dispose();
    });

    test('send is a no-op when not connected', () {
      expect(
        () => client.send({'type': 'test'}),
        returnsNormally,
      );
    });

    test('emits disconnected after disconnect()', () async {
      final statuses = <WebSocketClientStatus>[];
      final sub = client.status.listen(statuses.add);

      await client.connect();
      // Let any server-initiated events settle.
      await Future<void>.delayed(Duration.zero);

      await client.disconnect();

      expect(statuses, contains(WebSocketClientStatus.disconnected));

      await sub.cancel();
    });
  });
}
