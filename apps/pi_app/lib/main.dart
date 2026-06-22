import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/connections/bloc/connection_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/features/eq/bloc/eq_bloc.dart';
import 'package:pi_app/features/home/widgets/home_screen.dart';
import 'package:pi_app/features/led/bloc/led_bloc.dart';
import 'package:pi_app/features/now_playing/bloc/now_playing_bloc.dart';
import 'package:pi_app/features/visualizer/bloc/visualizer_bloc.dart';

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
  @override
  void initState() {
    super.initState();
    context.read<ConnectionBloc>().add(ConnectionStarted());
    context.read<VisualizerBloc>().add(VisualizerStarted());
    context.read<LedBloc>().add(LedStarted());
    context.read<NowPlayingBloc>().add(NowPlayingStarted());
    context.read<EqBloc>().add(EqStarted());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: HomeScreen(),
    );
  }
}
