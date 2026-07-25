import 'package:bt_speaker/features/connection/bloc/connection_bloc.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/connection/widgets/connection_screen.dart';
import 'package:bt_speaker/features/now_playing/data/spotify_auth_gateway.dart';
import 'package:bt_speaker/features/now_playing/data/spotify_service.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const PhoneApp());

/// Root widget for the BT Speaker phone app.
class PhoneApp extends StatefulWidget {
  /// Creates a [PhoneApp].
  const PhoneApp({super.key});

  @override
  State<PhoneApp> createState() => _PhoneAppState();
}

class _PhoneAppState extends State<PhoneApp> {
  final _spotifyService = SpotifyService();
  late final _authGateway = SpotifyAuthGateway(spotifyService: _spotifyService);

  @override
  void initState() {
    super.initState();
    // Must start at app root, not from a nested screen: iOS can kill the app
    // while Safari shows the Spotify login, so the redirect may be what
    // relaunches the process, before any screen below this one exists.
    _authGateway.start();
  }

  @override
  void dispose() {
    _authGateway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SpotifyService>.value(value: _spotifyService),
        RepositoryProvider<SpotifyAuthGateway>.value(value: _authGateway),
      ],
      child: BlocProvider(
        create: (_) => ConnectionBloc(
          clientFactory: (host) => WebSocketClient(host: host),
        ),
        child: const MaterialApp(title: 'BT Speaker', home: ConnectionScreen()),
      ),
    );
  }
}
