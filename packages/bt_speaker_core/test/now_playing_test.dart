import 'package:bt_speaker_core/now_playing.dart';
import 'package:bt_speaker_core/websocket_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NowPlaying', () {
    const nowPlaying = NowPlaying(
      title: 'Song Title',
      artist: 'The Artist',
      album: 'The Album',
      albumArtBase64: 'YWJj',
      progressMs: 30000,
      durationMs: 200000,
    );

    group('constructor', () {
      test('assigns track metadata correctly', () {
        expect(nowPlaying.title, equals('Song Title'));
        expect(nowPlaying.artist, equals('The Artist'));
        expect(nowPlaying.album, equals('The Album'));
      });

      test('assigns progress and duration correctly', () {
        expect(nowPlaying.progressMs, equals(30000));
        expect(nowPlaying.durationMs, equals(200000));
      });

      test('albumArtBase64 defaults to null when omitted', () {
        const track = NowPlaying(
          title: 't',
          artist: 'a',
          album: 'al',
          progressMs: 0,
          durationMs: 1,
        );
        expect(track.albumArtBase64, isNull);
      });
    });

    group('fromJson', () {
      final validJson = {
        'title': 'Song Title',
        'artist': 'The Artist',
        'album': 'The Album',
        'album_art_base64': 'YWJj',
        'progress_ms': 30000,
        'duration_ms': 200000,
      };

      test('parses all fields from JSON', () {
        final result = NowPlaying.fromJson(validJson);

        expect(result.title, equals('Song Title'));
        expect(result.artist, equals('The Artist'));
        expect(result.album, equals('The Album'));
        expect(result.albumArtBase64, equals('YWJj'));
        expect(result.progressMs, equals(30000));
        expect(result.durationMs, equals(200000));
      });

      test('parses a null album_art_base64', () {
        final json = {...validJson, 'album_art_base64': null};
        expect(NowPlaying.fromJson(json).albumArtBase64, isNull);
      });

      test('throws when title is missing', () {
        final json = {...validJson}..remove('title');
        expect(() => NowPlaying.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('throws when progress_ms has the wrong type', () {
        final json = {...validJson, 'progress_ms': '30000'};
        expect(() => NowPlaying.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      late Map<String, dynamic> json;

      setUp(() {
        json = nowPlaying.toJson();
      });

      test('includes the correct event type key', () {
        expect(json['type'], equals(kNowPlaying));
      });

      test('serialises track metadata correctly', () {
        expect(json['title'], equals('Song Title'));
        expect(json['artist'], equals('The Artist'));
        expect(json['album'], equals('The Album'));
        expect(json['album_art_base64'], equals('YWJj'));
      });

      test('serialises progress and duration correctly', () {
        expect(json['progress_ms'], equals(30000));
        expect(json['duration_ms'], equals(200000));
      });

      test('serialises a null albumArtBase64 as a null value, not omitted', () {
        const track = NowPlaying(
          title: 't',
          artist: 'a',
          album: 'al',
          progressMs: 0,
          durationMs: 1,
        );
        final result = track.toJson();

        expect(result.containsKey('album_art_base64'), isTrue);
        expect(result['album_art_base64'], isNull);
      });

      test('contains exactly seven keys', () {
        expect(
          json.keys,
          containsAll([
            'type',
            'title',
            'artist',
            'album',
            'album_art_base64',
            'progress_ms',
            'duration_ms',
          ]),
        );
        expect(json.length, equals(7));
      });
    });

    group('fromJson → toJson round-trip', () {
      test('preserves all fields after a round-trip', () {
        final original = nowPlaying.toJson();
        final restored = NowPlaying.fromJson(original);
        final result = restored.toJson();

        expect(result, equals(original));
      });
    });
  });
}
