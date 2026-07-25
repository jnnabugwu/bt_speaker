import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/now_playing/bloc/now_playing_bloc.dart';
import 'package:bt_speaker/features/now_playing/data/spotify_service.dart';
import 'package:bt_speaker_core/now_playing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements WebSocketClient {}

class _MockSpotifyService extends Mock implements SpotifyService {}

void main() {
  group('NowPlayingBloc', () {
    late _MockClient client;
    late _MockSpotifyService spotify;

    setUp(() {
      client = _MockClient();
      spotify = _MockSpotifyService();
      when(() => client.send(any())).thenReturn(null);
    });

    blocTest<NowPlayingBloc, NowPlayingState>(
      'emits Idle and starts polling when already authenticated on start',
      setUp: () {
        when(() => spotify.isAuthenticated).thenAnswer((_) async => true);
        when(() => spotify.currentlyPlaying()).thenAnswer((_) async => null);
      },
      build: () => NowPlayingBloc(
        client: client,
        spotifyService: spotify,
        authCompleted: const Stream.empty(),
      ),
      act: (bloc) => bloc.add(const NowPlayingStarted()),
      expect: () => [isA<NowPlayingIdle>()],
    );

    blocTest<NowPlayingBloc, NowPlayingState>(
      'stays Unauthenticated on start when not authenticated',
      setUp: () {
        when(() => spotify.isAuthenticated).thenAnswer((_) async => false);
      },
      build: () => NowPlayingBloc(
        client: client,
        spotifyService: spotify,
        authCompleted: const Stream.empty(),
      ),
      act: (bloc) => bloc.add(const NowPlayingStarted()),
      expect: () => <NowPlayingState>[],
    );

    blocTest<NowPlayingBloc, NowPlayingState>(
      'opens the Spotify login page on auth request',
      setUp: () {
        when(() => spotify.authenticate()).thenAnswer((_) async {});
      },
      build: () => NowPlayingBloc(
        client: client,
        spotifyService: spotify,
        authCompleted: const Stream.empty(),
      ),
      act: (bloc) => bloc.add(const NowPlayingAuthRequested()),
      expect: () => <NowPlayingState>[],
      verify: (_) => verify(() => spotify.authenticate()).called(1),
    );

    blocTest<NowPlayingBloc, NowPlayingState>(
      'clears tokens and emits Unauthenticated on logout',
      seed: () => const NowPlayingIdle(),
      setUp: () {
        when(() => spotify.logout()).thenAnswer((_) async {});
      },
      build: () => NowPlayingBloc(
        client: client,
        spotifyService: spotify,
        authCompleted: const Stream.empty(),
      ),
      act: (bloc) => bloc.add(const NowPlayingLogoutRequested()),
      expect: () => [isA<NowPlayingUnauthenticated>()],
      verify: (_) => verify(() => spotify.logout()).called(1),
    );

    test(
      'starts polling and pushes to the Pi when the auth gateway completes',
      () async {
        final authController = StreamController<void>();
        const track = NowPlaying(
          title: 'Song',
          artist: 'Artist',
          album: 'Album',
          progressMs: 0,
          durationMs: 1000,
        );
        when(() => spotify.isAuthenticated).thenAnswer((_) async => true);
        when(() => spotify.currentlyPlaying()).thenAnswer((_) async => track);

        final bloc = NowPlayingBloc(
          client: client,
          spotifyService: spotify,
          authCompleted: authController.stream,
        );
        addTearDown(bloc.close);
        addTearDown(authController.close);

        final states = <NowPlayingState>[];
        final sub = bloc.stream.listen(states.add);
        addTearDown(sub.cancel);

        authController.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 3300));

        expect(states, contains(isA<NowPlayingIdle>()));
        expect(states.last, isA<NowPlayingActive>());
        verify(() => client.send(track.toJson())).called(1);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}
