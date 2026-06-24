import 'package:bt_speaker/features/connection/bloc/connection_bloc.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/connection/widgets/connection_screen.dart';
import 'package:bt_speaker/features/eq/bloc/eq_bloc.dart';
import 'package:bt_speaker/features/eq/widgets/eq_screen.dart';
import 'package:bt_speaker/features/led/bloc/led_bloc.dart';
import 'package:bt_speaker/features/led/widgets/led_screen.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Main screen shown after a successful connection.
/// Hosts EQ and LED tabs, each backed by their own BLoC.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen] with an open [client].
  const HomeScreen({required this.client, super.key});

  /// The active WebSocket client passed from [ConnectionScreen].
  final WebSocketClient client;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _disconnect(BuildContext context) {
    context.read<ConnectionBloc>().add(ConnectionDisconnectRequested());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ConnectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EqBloc(client: widget.client)),
        BlocProvider(create: (_) => LedBloc(client: widget.client)),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('BT Speaker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bluetooth_disabled),
                onPressed: () => _disconnect(context),
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: const [EqScreen(), LedScreen()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) =>
                setState(() => _selectedIndex = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.graphic_eq),
                label: 'EQ',
              ),
              NavigationDestination(
                icon: Icon(Icons.lightbulb_outline),
                label: 'LED',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
