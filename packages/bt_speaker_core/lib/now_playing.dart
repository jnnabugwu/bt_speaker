import 'package:bt_speaker_core/websocket_events.dart';

///NowPlaying is the information for the now playing song
class NowPlaying {
  /// Creates now playing information from a JSON map.
  const NowPlaying({
    required this.title,
    required this.artist,
    required this.album,
    required this.progressMs,
    required this.durationMs,
    this.albumArtBase64,
  });

  /// Creates now playing information from a JSON map.
  factory NowPlaying.fromJson(Map<String, dynamic> json) {
    return NowPlaying(
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      albumArtBase64: json['album_art_base64'] as String?,
      progressMs: json['progress_ms'] as int,
      durationMs: json['duration_ms'] as int,
    );
  }

  ///the title of the song
  final String title;

  ///the artist of the song
  final String artist;

  ///the album of the song
  final String album;

  ///the album art base64
  final String? albumArtBase64;

  ///the progress of the song in milliseconds
  final int progressMs;

  ///the duration of the song in milliseconds
  final int durationMs;

  /// Converts the now playing information to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': kNowPlaying,
    'title': title,
    'artist': artist,
    'album': album,
    'album_art_base64': albumArtBase64,
    'progress_ms': progressMs,
    'duration_ms': durationMs,
  };
}
