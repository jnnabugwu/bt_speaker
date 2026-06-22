import 'dart:convert';

import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pi_app/features/now_playing/bloc/now_playing_bloc.dart';

/// Displays current track metadata at the bottom of the screen.
///
/// Shows a progress bar, title, artist/album text, and optional album art.
/// Falls back to a placeholder while [NowPlayingIdle].
class NowPlayingBar extends StatelessWidget {
  /// Creates a [NowPlayingBar].
  const NowPlayingBar({super.key});

  static const double _height = 72;
  static const double _artSize = 48;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NowPlayingBloc, NowPlayingState>(
      builder: (context, state) {
        return switch (state) {
          NowPlayingIdle() => _buildIdle(),
          NowPlayingActive(:final track) => _buildActive(track),
        };
      },
    );
  }

  Widget _buildIdle() {
    return const SizedBox(
      height: _height,
      child: Center(
        child: Text(
          'Waiting for connection...',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildActive(NowPlaying track) {
    final progress =
        track.durationMs > 0 ? track.progressMs / track.durationMs : 0.0;

    return SizedBox(
      height: _height,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 3,
            color: Colors.cyanAccent,
            backgroundColor: Colors.white12,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${track.artist} — ${track.album}',
                          style: const TextStyle(color: Colors.white54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _AlbumArt(base64: track.albumArtBase64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.base64});

  final String? base64;

  @override
  Widget build(BuildContext context) {
    final art = base64;
    if (art != null) {
      return Image.memory(
        base64Decode(art),
        width: NowPlayingBar._artSize,
        height: NowPlayingBar._artSize,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox(
      width: NowPlayingBar._artSize,
      height: NowPlayingBar._artSize,
      child: Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
