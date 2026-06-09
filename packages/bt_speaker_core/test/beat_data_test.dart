import 'package:bt_speaker_core/beat_data.dart';
import 'package:bt_speaker_core/websocket_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeatData', () {
    const testBpm = 120;
    const testIntensity = 0.75;
    const testFftBars = [0.1, 0.5, 0.9, 0.3, 0.7];

    const beatData = BeatData(
      bpm: testBpm,
      intensity: testIntensity,
      fftBars: testFftBars,
    );

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------
    group('constructor', () {
      test('assigns bpm correctly', () {
        expect(beatData.bpm, equals(testBpm));
      });

      test('assigns intensity correctly', () {
        expect(beatData.intensity, equals(testIntensity));
      });

      test('assigns fftBars correctly', () {
        expect(beatData.fftBars, equals(testFftBars));
      });
    });

    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      final validJson = {
        'bpm': 140,
        'intensity': 0.5,
        'fft_bars': [0.2, 0.4, 0.6],
      };

      test('parses bpm from JSON', () {
        final result = BeatData.fromJson(validJson);
        expect(result.bpm, equals(140));
      });

      test('parses intensity from JSON', () {
        final result = BeatData.fromJson(validJson);
        expect(result.intensity, equals(0.5));
      });

      test('parses fftBars from JSON', () {
        final result = BeatData.fromJson(validJson);
        expect(result.fftBars, equals([0.2, 0.4, 0.6]));
      });

      test('parses an empty fftBars list', () {
        final json = {'bpm': 100, 'intensity': 0.0, 'fft_bars': <double>[]};
        final result = BeatData.fromJson(json);
        expect(result.fftBars, isEmpty);
      });

      test('throws when bpm is missing', () {
        final json = {
          'intensity': 0.5,
          'fft_bars': [0.1],
        };
        expect(() => BeatData.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('throws when intensity is missing', () {
        final json = {
          'bpm': 120,
          'fft_bars': [0.1],
        };
        expect(() => BeatData.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('throws when fft_bars is missing', () {
        final json = {'bpm': 120, 'intensity': 0.5};
        expect(() => BeatData.fromJson(json), throwsA(isA<Error>()));
      });

      test('throws when bpm has wrong type', () {
        final json = {
          'bpm': '120',
          'intensity': 0.5,
          'fft_bars': [0.1],
        };
        expect(() => BeatData.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late Map<String, dynamic> json;

      setUp(() {
        json = beatData.toJson();
      });

      test('includes the correct event type key', () {
        expect(json['type'], equals(kBeatEvent));
      });

      test('serialises bpm correctly', () {
        expect(json['bpm'], equals(testBpm));
      });

      test('serialises intensity correctly', () {
        expect(json['intensity'], equals(testIntensity));
      });

      test('serialises fftBars correctly', () {
        expect(json['fft_bars'], equals(testFftBars));
      });

      test('contains exactly four keys', () {
        expect(
          json.keys,
          containsAll(['type', 'bpm', 'intensity', 'fft_bars']),
        );
        expect(json.length, equals(4));
      });
    });

    // -------------------------------------------------------------------------
    // Round-trip
    // -------------------------------------------------------------------------
    group('fromJson → toJson round-trip', () {
      test('preserves all fields after a round-trip', () {
        final original = beatData.toJson();
        final restored = BeatData.fromJson(original);
        final result = restored.toJson();

        expect(result['bpm'], equals(original['bpm']));
        expect(result['intensity'], equals(original['intensity']));
        expect(result['fft_bars'], equals(original['fft_bars']));
        expect(result['type'], equals(kBeatEvent));
      });
    });

    // -------------------------------------------------------------------------
    // Edge cases
    // -------------------------------------------------------------------------
    group('edge cases', () {
      test('handles zero bpm', () {
        const data = BeatData(bpm: 0, intensity: 0, fftBars: []);
        expect(data.bpm, equals(0));
      });

      test('handles maximum intensity of 1.0', () {
        const data = BeatData(bpm: 200, intensity: 1, fftBars: []);
        expect(data.intensity, equals(1.0));
      });

      test('handles large fftBars list', () {
        final bars = List<double>.generate(1024, (i) => i / 1024);
        final data = BeatData(bpm: 120, intensity: 0.5, fftBars: bars);
        expect(data.fftBars.length, equals(1024));
      });
    });
  });
}
