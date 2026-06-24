import 'package:bt_speaker/features/connection/bloc/connection_bloc.dart';
import 'package:bt_speaker/features/home/widgets/home_screen.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Entry screen — lets the user enter the Pi's IP and tap Connect.
class ConnectionScreen extends StatefulWidget {
  /// Creates a [ConnectionScreen].
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _controller = TextEditingController(text: '192.168.1.70');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BT Speaker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: BlocConsumer<ConnectionBloc, ConnectionState>(
            listener: (context, state) {
              if (state is ConnectionConnected) {
                final client =
                    context.read<ConnectionBloc>().activeClient!;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => HomeScreen(client: client),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Raspberry Pi Address'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAction(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, ConnectionState state) {
    if (state is ConnectionConnecting) {
      return const CircularProgressIndicator();
    }
    if (state is ConnectionFailed) {
      return Column(
        children: [
          Text(
            state.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _connect(context),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    return ElevatedButton(
      onPressed: _connect(context),
      child: const Text('Connect'),
    );
  }

  VoidCallback _connect(BuildContext context) => () {
        context.read<ConnectionBloc>().add(
              ConnectionConnectRequested(_controller.text.trim()),
            );
      };
}
