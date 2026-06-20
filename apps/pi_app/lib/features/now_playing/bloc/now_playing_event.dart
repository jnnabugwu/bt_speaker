part of 'now_playing_bloc.dart';

///All events the [NowPlayingBloc] can receive
sealed class NowPlayingEvent {}

///Starts listening to the WebSocket events stream for now playing updates
final class NowPlayingStarted extends NowPlayingEvent {}

///Stops listening and resets to idle
final class NowPlayingStopped extends NowPlayingEvent {}

///Internal — fired from the events stream; do not add externally
final class NowPlayingTrackReceived extends NowPlayingEvent {
  ///Creates a [NowPlayingTrackReceived] with the given [track]
  NowPlayingTrackReceived(this.track);

  ///The now playing payload
  final NowPlaying track;
}
