import 'dart:async';

import 'package:bt_speaker_core/led_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/bloc/connection_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/eq/bloc/eq_bloc.dart';
import 'package:pi_app/features/home/widgets/home_screen.dart';
import 'package:pi_app/features/led/bloc/led_bloc.dart';
import 'package:pi_app/features/led/data/led_driver.dart';
import 'package:pi_app/features/now_playing/bloc/now_playing_bloc.dart';
import 'package:pi_app/features/visualizer/bloc/visualizer_bloc.dart';

const _ledDaemonPath = '/home/jnnabugwu/bt_speaker/led_daemon.py';

void main() {
  final server = WebSocketServer();
  runApp(MyApp(server: server));
}

///Root widget for the Pi app
class MyApp extends StatelessWidget {
  ///Creates [MyApp] with the given [WebSocketServer]
  const MyApp({required this.server, super.key});

  ///The shared WebSocket server instance
  final WebSocketServer server;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectionBloc(server: server)),
        BlocProvider(create: (_) => VisualizerBloc(server: server)),
        BlocProvider(create: (_) => LedBloc(server: server)),
        BlocProvider(create: (_) => NowPlayingBloc(server: server)),
        BlocProvider(create: (_) => EqBloc(server: server)),
      ],
      child: const MaterialApp(title: 'BT Speaker', home: AppRoot()),
    );
  }
}

///Provisions all blocs on startup and holds the app scaffold
class AppRoot extends StatefulWidget {
  ///Creates an [AppRoot]
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _ledDriver = LedDriver();
  StreamSubscription<LedState>? _ledSub;

  @override
  void initState() {
    super.initState();
    context.read<ConnectionBloc>().add(ConnectionStarted());
    context.read<VisualizerBloc>().add(VisualizerStarted());
    context.read<LedBloc>().add(LedStarted());
    context.read<NowPlayingBloc>().add(NowPlayingStarted());
    context.read<EqBloc>().add(EqStarted());

    unawaited(_ledDriver.start(_ledDaemonPath));
    _ledSub = context.read<LedBloc>().stream.listen((state) {
      if (state is LedActive) {
        _ledDriver.apply(state.command);
      } else if (state is LedIdle) {
        _ledDriver.apply(
          const LedCommand(mode: LedMode.off, r: 0, g: 0, b: 0, brightness: 0),
        );
      }
    });
  }

  @override
  void dispose() {
    _ledSub?.cancel();
    unawaited(_ledDriver.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.black, body: HomeScreen());
  }
}
