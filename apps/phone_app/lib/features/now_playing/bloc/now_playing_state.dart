part of 'now_playing_bloc.dart';

/// Base class for all [NowPlayingBloc] states.
sealed class NowPlayingState extends Equatable {
  const NowPlayingState();
}

/// Spotify is not connected — show "Connect Spotify" button.
final class NowPlayingUnauthenticated extends NowPlayingState {
  /// Creates a [NowPlayingUnauthenticated] state.
  const NowPlayingUnauthenticated();

  @override
  List<Object?> get props => [];
}

/// Authenticated but nothing is currently playing.
final class NowPlayingIdle extends NowPlayingState {
  /// Creates a [NowPlayingIdle] state.
  const NowPlayingIdle();

  @override
  List<Object?> get props => [];
}

/// A track is actively playing.
final class NowPlayingActive extends NowPlayingState {
  /// Creates a [NowPlayingActive] state with the given [track].
  const NowPlayingActive(this.track);

  /// The currently playing track.
  final NowPlaying track;

  @override
  List<Object?> get props => [track];
}
