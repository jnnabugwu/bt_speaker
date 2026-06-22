import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker_core/bt_speaker_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/now_playing/bloc/now_playing_bloc.dart';
import 'package:pi_app/features/now_playing/widgets/now_playing_bar.dart';

class _MockNowPlayingBloc extends MockBloc<NowPlayingEvent, NowPlayingState>
    implements NowPlayingBloc {}

// Minimal 1x1 white PNG for album-art tests.
final Uint8List _kOnePx = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
  'AAAADUlEQVR42mP8z8BQDwADhQGAWjR9awAAAABJRU5ErkJggg==',
);

Widget _wrap(NowPlayingBloc bloc) {
  return MaterialApp(
    home: BlocProvider<NowPlayingBloc>.value(
      value: bloc,
      child: const Scaffold(body: NowPlayingBar()),
    ),
  );
}

NowPlaying _track({String? albumArtBase64}) => NowPlaying(
  title: 'Song',
  artist: 'Artist',
  album: 'Album',
  progressMs: 30000,
  durationMs: 240000,
  albumArtBase64: albumArtBase64,
);

void main() {
  group('NowPlayingBar', () {
    late _MockNowPlayingBloc bloc;

    setUp(() => bloc = _MockNowPlayingBloc());
    tearDown(() => bloc.close());

    testWidgets('shows idle placeholder when NowPlayingIdle', (tester) async {
      whenListen(
        bloc,
        Stream<NowPlayingState>.value(const NowPlayingIdle()),
        initialState: const NowPlayingIdle(),
      );
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text('Waiting for connection...'), findsOneWidget);
    });

    testWidgets('shows title and artist when NowPlayingActive', (tester) async {
      final state = NowPlayingActive(_track());
      whenListen(
        bloc,
        Stream<NowPlayingState>.value(state),
        initialState: state,
      );
      await tester.pumpWidget(_wrap(bloc));
      expect(find.text('Song'), findsOneWidget);
      expect(find.text('Artist — Album'), findsOneWidget);
    });

    testWidgets('progress indicator has correct value', (tester) async {
      final state = NowPlayingActive(_track());
      whenListen(
        bloc,
        Stream<NowPlayingState>.value(state),
        initialState: state,
      );
      await tester.pumpWidget(_wrap(bloc));
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(30000 / 240000, 0.0001));
    });

    testWidgets('shows album art image when albumArtBase64 is provided', (
      tester,
    ) async {
      final state = NowPlayingActive(
        _track(albumArtBase64: base64Encode(_kOnePx)),
      );
      whenListen(
        bloc,
        Stream<NowPlayingState>.value(state),
        initialState: state,
      );
      await tester.pumpWidget(_wrap(bloc));
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows music_note icon when albumArtBase64 is null', (
      tester,
    ) async {
      final state = NowPlayingActive(_track());
      whenListen(
        bloc,
        Stream<NowPlayingState>.value(state),
        initialState: state,
      );
      await tester.pumpWidget(_wrap(bloc));
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });
  });
}
