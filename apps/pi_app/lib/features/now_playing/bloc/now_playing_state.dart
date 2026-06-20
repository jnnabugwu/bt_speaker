part of 'now_playing_bloc.dart';

///All states the [NowPlayingBloc] can emit
sealed class NowPlayingState extends Equatable {
  const NowPlayingState();
}

///Not listening for now playing updates
final class NowPlayingIdle extends NowPlayingState {
  ///Creates a [NowPlayingIdle] state
  const NowPlayingIdle();

  @override
  List<Object?> get props => [];
}

///Actively receiving now playing updates from the phone
final class NowPlayingActive extends NowPlayingState {
  ///Creates a [NowPlayingActive] state with the given [track]
  const NowPlayingActive(this.track);

  ///The most recently received track info
  final NowPlaying track;

  @override
  List<Object?> get props => [track];
}
