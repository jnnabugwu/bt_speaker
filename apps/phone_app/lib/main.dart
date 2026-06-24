import 'package:bt_speaker/features/connection/bloc/connection_bloc.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/connection/widgets/connection_screen.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const PhoneApp());

/// Root widget for the BT Speaker phone app.
class PhoneApp extends StatelessWidget {
  /// Creates a [PhoneApp].
  const PhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConnectionBloc(
        clientFactory: (host) => WebSocketClient(host: host),
      ),
      child: const MaterialApp(
        title: 'BT Speaker',
        home: ConnectionScreen(),
      ),
    );
  }
}
