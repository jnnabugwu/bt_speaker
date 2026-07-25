part of 'now_playing_bloc.dart';

/// Base class for all [NowPlayingBloc] events.
sealed class NowPlayingEvent extends Equatable {
  const NowPlayingEvent();
}

/// Fired on startup — checks if already authenticated and begins polling.
final class NowPlayingStarted extends NowPlayingEvent {
  /// Creates a [NowPlayingStarted] event.
  const NowPlayingStarted();

  @override
  List<Object?> get props => [];
}

/// User tapped "Connect Spotify" — opens the browser auth flow.
final class NowPlayingAuthRequested extends NowPlayingEvent {
  /// Creates a [NowPlayingAuthRequested] event.
  const NowPlayingAuthRequested();

  @override
  List<Object?> get props => [];
}

/// The app-level auth gateway finished exchanging an auth code for tokens.
final class NowPlayingAuthCompleted extends NowPlayingEvent {
  /// Creates a [NowPlayingAuthCompleted] event.
  const NowPlayingAuthCompleted();

  @override
  List<Object?> get props => [];
}

/// User requested to disconnect Spotify.
final class NowPlayingLogoutRequested extends NowPlayingEvent {
  /// Creates a [NowPlayingLogoutRequested] event.
  const NowPlayingLogoutRequested();

  @override
  List<Object?> get props => [];
}

/// Internal — fired by the polling timer.
final class _NowPlayingPolled extends NowPlayingEvent {
  const _NowPlayingPolled();

  @override
  List<Object?> get props => [];
}
