import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/now_playing/bloc/now_playing_bloc.dart';
import 'package:bt_speaker/features/now_playing/widgets/now_playing_screen.dart';
import 'package:bt_speaker_core/now_playing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNowPlayingBloc extends MockBloc<NowPlayingEvent, NowPlayingState>
    implements NowPlayingBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const NowPlayingAuthRequested());
  });

  group('NowPlayingScreen', () {
    late _MockNowPlayingBloc bloc;

    setUp(() => bloc = _MockNowPlayingBloc());

    tearDown(() => bloc.close());

    Widget buildSubject() => BlocProvider<NowPlayingBloc>.value(
      value: bloc,
      child: const MaterialApp(home: Scaffold(body: NowPlayingScreen())),
    );

    testWidgets('shows Connect Spotify button when unauthenticated', (
      tester,
    ) async {
      whenListen(
        bloc,
        const Stream<NowPlayingState>.empty(),
        initialState: const NowPlayingUnauthenticated(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Connect Spotify'), findsOneWidget);
    });

    testWidgets('dispatches auth request on Connect Spotify tap', (
      tester,
    ) async {
      whenListen(
        bloc,
        const Stream<NowPlayingState>.empty(),
        initialState: const NowPlayingUnauthenticated(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Connect Spotify'));
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<NowPlayingAuthRequested>())),
      ).called(1);
    });

    testWidgets('shows "Nothing playing" when idle', (tester) async {
      whenListen(
        bloc,
        const Stream<NowPlayingState>.empty(),
        initialState: const NowPlayingIdle(),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Nothing playing'), findsOneWidget);
    });

    testWidgets('shows track details when a track is active', (tester) async {
      const track = NowPlaying(
        title: 'Song Title',
        artist: 'The Artist',
        album: 'The Album',
        progressMs: 30000,
        durationMs: 120000,
      );
      whenListen(
        bloc,
        const Stream<NowPlayingState>.empty(),
        initialState: const NowPlayingActive(track),
      );

      await tester.pumpWidget(buildSubject());

      expect(find.text('Song Title'), findsOneWidget);
      expect(find.text('The Artist'), findsOneWidget);
      expect(find.text('The Album'), findsOneWidget);
      expect(find.text('Disconnect Spotify'), findsOneWidget);
    });

    testWidgets('dispatches logout on Disconnect Spotify tap', (tester) async {
      const track = NowPlaying(
        title: 'Song Title',
        artist: 'The Artist',
        album: 'The Album',
        progressMs: 30000,
        durationMs: 120000,
      );
      whenListen(
        bloc,
        const Stream<NowPlayingState>.empty(),
        initialState: const NowPlayingActive(track),
      );

      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Disconnect Spotify'));
      await tester.pump();

      verify(
        () => bloc.add(any(that: isA<NowPlayingLogoutRequested>())),
      ).called(1);
    });
  });
}
