import 'dart:convert';

import 'package:bt_speaker/features/now_playing/bloc/now_playing_bloc.dart';
import 'package:bt_speaker_core/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen that shows the currently playing Spotify track and sends it to Pi.
class NowPlayingScreen extends StatelessWidget {
  /// Creates a [NowPlayingScreen].
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NowPlayingBloc, NowPlayingState>(
      builder: (context, state) => switch (state) {
        NowPlayingUnauthenticated() => const _UnauthView(),
        NowPlayingIdle() => const _IdleView(),
        NowPlayingActive(:final track) => _ActiveView(track: track),
      },
    );
  }
}

class _UnauthView extends StatelessWidget {
  const _UnauthView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Connect Spotify to see what's playing"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Connect Spotify'),
            onPressed: () => context
                .read<NowPlayingBloc>()
                .add(const NowPlayingAuthRequested()),
          ),
        ],
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nothing playing'),
        ],
      ),
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.track});

  final NowPlaying track;

  @override
  Widget build(BuildContext context) {
    final artBase64 = track.albumArtBase64;
    final art = artBase64 != null
        ? Image.memory(
            base64Decode(artBase64),
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          )
        : const SizedBox(
            width: 160,
            height: 160,
            child: Icon(Icons.album, size: 64, color: Colors.grey),
          );

    final progress = track.durationMs > 0
        ? track.progressMs / track.durationMs
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: art),
          const SizedBox(height: 24),
          Text(
            track.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            track.artist,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            track.album,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
          const SizedBox(height: 24),
          TextButton.icon(
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Disconnect Spotify'),
            onPressed: () => context
                .read<NowPlayingBloc>()
                .add(const NowPlayingLogoutRequested()),
          ),
        ],
      ),
    );
  }
}
