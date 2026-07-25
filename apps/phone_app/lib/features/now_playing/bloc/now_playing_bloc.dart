import 'dart:async';

import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/now_playing/data/spotify_service.dart';
import 'package:bt_speaker_core/now_playing.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'now_playing_event.dart';
part 'now_playing_state.dart';

const _pollInterval = Duration(seconds: 3);

/// Polls Spotify for the currently playing track and forwards it to the Pi.
class NowPlayingBloc extends Bloc<NowPlayingEvent, NowPlayingState> {
  /// Creates a [NowPlayingBloc] that sends updates through [client].
  ///
  /// [authCompleted] should be the stream from the app-level
  /// `SpotifyAuthGateway`, which performs the token exchange independently
  /// of this bloc's lifecycle — this bloc only reacts to it.
  NowPlayingBloc({
    required WebSocketClient client,
    required SpotifyService spotifyService,
    required Stream<void> authCompleted,
  }) : _client = client,
       _spotify = spotifyService,
       super(const NowPlayingUnauthenticated()) {
    on<NowPlayingStarted>(_onStarted);
    on<NowPlayingAuthRequested>(_onAuthRequested);
    on<NowPlayingAuthCompleted>(_onAuthCompleted);
    on<NowPlayingLogoutRequested>(_onLogoutRequested);
    on<_NowPlayingPolled>(_onPolled);
    _authSub = authCompleted.listen(
      (_) => add(const NowPlayingAuthCompleted()),
    );
  }

  final WebSocketClient _client;
  final SpotifyService _spotify;
  Timer? _timer;
  StreamSubscription<void>? _authSub;
  NowPlaying? _lastTrack;

  Future<void> _onStarted(
    NowPlayingStarted event,
    Emitter<NowPlayingState> emit,
  ) async {
    if (await _spotify.isAuthenticated) {
      emit(const NowPlayingIdle());
      _startPolling();
    }
  }

  Future<void> _onAuthRequested(
    NowPlayingAuthRequested event,
    Emitter<NowPlayingState> emit,
  ) async {
    await _spotify.authenticate();
  }

  Future<void> _onAuthCompleted(
    NowPlayingAuthCompleted event,
    Emitter<NowPlayingState> emit,
  ) async {
    if (!await _spotify.isAuthenticated) return;
    emit(const NowPlayingIdle());
    _startPolling();
  }

  Future<void> _onLogoutRequested(
    NowPlayingLogoutRequested event,
    Emitter<NowPlayingState> emit,
  ) async {
    _stopPolling();
    await _spotify.logout();
    _lastTrack = null;
    emit(const NowPlayingUnauthenticated());
  }

  Future<void> _onPolled(
    _NowPlayingPolled event,
    Emitter<NowPlayingState> emit,
  ) async {
    final track = await _spotify.currentlyPlaying();
    if (track == null) {
      if (state is! NowPlayingIdle) emit(const NowPlayingIdle());
      return;
    }
    if (track.title != _lastTrack?.title ||
        track.artist != _lastTrack?.artist) {
      _client.send(track.toJson());
    }
    _lastTrack = track;
    emit(NowPlayingActive(track));
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      _pollInterval,
      (_) => add(const _NowPlayingPolled()),
    );
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    unawaited(_authSub?.cancel());
    return super.close();
  }
}
