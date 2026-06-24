import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/connection/bloc/connection_bloc.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake [WebSocketClient] that emits a configurable status sequence.
class _FakeClient extends WebSocketClient {
  _FakeClient({required this.statusSequence}) : super(host: 'fake', port: 0);

  final List<WebSocketClientStatus> statusSequence;
  final _controller = StreamController<WebSocketClientStatus>.broadcast();

  @override
  Stream<WebSocketClientStatus> get status => _controller.stream;

  @override
  Future<void> connect() async {
    for (final s in statusSequence) {
      _controller.add(s);
    }
  }

  @override
  Future<void> disconnect() async {
    _controller.add(WebSocketClientStatus.disconnected);
  }

  @override
  Future<void> dispose() async => _controller.close();
}

void main() {
  group('ConnectionBloc', () {
    blocTest<ConnectionBloc, ConnectionState>(
      'emits connecting then connected on successful connect',
      build: () => ConnectionBloc(
        clientFactory: (_) => _FakeClient(
          statusSequence: [
            WebSocketClientStatus.connecting,
            WebSocketClientStatus.connected,
          ],
        ),
      ),
      act: (bloc) => bloc.add(ConnectionConnectRequested('192.168.1.70')),
      expect: () => [isA<ConnectionConnecting>(), isA<ConnectionConnected>()],
    );

    blocTest<ConnectionBloc, ConnectionState>(
      'emits ConnectionFailed on error status',
      build: () => ConnectionBloc(
        clientFactory: (_) => _FakeClient(
          statusSequence: [
            WebSocketClientStatus.connecting,
            WebSocketClientStatus.error,
          ],
        ),
      ),
      act: (bloc) => bloc.add(ConnectionConnectRequested('192.168.1.70')),
      expect: () => [isA<ConnectionConnecting>(), isA<ConnectionFailed>()],
    );

    blocTest<ConnectionBloc, ConnectionState>(
      'emits ConnectionIdle after disconnect',
      build: () => ConnectionBloc(
        clientFactory: (_) => _FakeClient(
          statusSequence: [
            WebSocketClientStatus.connecting,
            WebSocketClientStatus.connected,
          ],
        ),
      ),
      act: (bloc) async {
        bloc.add(ConnectionConnectRequested('192.168.1.70'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(ConnectionDisconnectRequested());
      },
      expect: () => [
        isA<ConnectionConnecting>(),
        isA<ConnectionConnected>(),
        isA<ConnectionIdle>(),
      ],
    );
  });
}
