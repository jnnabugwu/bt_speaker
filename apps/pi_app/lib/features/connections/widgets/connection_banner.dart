import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/bloc/connection_bloc.dart';

/// Displays a status strip when the phone is not connected.
///
/// Collapses to nothing when [ConnectionConnected]. Shows an orange strip
/// while waiting and a red strip on error.
class ConnectionBanner extends StatelessWidget {
  /// Creates a [ConnectionBanner].
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        return switch (state) {
          ConnectionConnected() => const SizedBox.shrink(),
          ConnectionWaiting() => const _Banner(
            label: 'Waiting for phone...',
            color: Color(0xFFE65100),
            icon: Icons.bluetooth_searching,
          ),
          ConnectionError() => const _Banner(
            label: 'Connection error — restarting',
            color: Color(0xFFB71C1C),
            icon: Icons.error_outline,
          ),
        };
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
