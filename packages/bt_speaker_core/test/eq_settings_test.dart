import 'package:bt_speaker_core/eq_settings.dart';
import 'package:bt_speaker_core/websocket_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EqSettings', () {
    const testBass = 3;
    const testMid = -2;
    const testTreble = 5;

    const eqSettings = EqSettings(
      bass: testBass,
      mid: testMid,
      treble: testTreble,
    );

    group('constructor', () {
      test('assigns bass correctly', () {
        expect(eqSettings.bass, equals(testBass));
      });

      test('assigns mid correctly', () {
        expect(eqSettings.mid, equals(testMid));
      });

      test('assigns treble correctly', () {
        expect(eqSettings.treble, equals(testTreble));
      });
    });

    group('fromJson', () {
      final validJson = {'bass': 1, 'mid': 2, 'treble': 3};

      test('parses bass from JSON', () {
        expect(EqSettings.fromJson(validJson).bass, equals(1));
      });

      test('parses mid from JSON', () {
        expect(EqSettings.fromJson(validJson).mid, equals(2));
      });

      test('parses treble from JSON', () {
        expect(EqSettings.fromJson(validJson).treble, equals(3));
      });

      test('parses negative values', () {
        final json = {'bass': -6, 'mid': -6, 'treble': -6};
        final result = EqSettings.fromJson(json);
        expect(result.bass, equals(-6));
        expect(result.mid, equals(-6));
        expect(result.treble, equals(-6));
      });

      test('throws when bass is missing', () {
        final json = {'mid': 1, 'treble': 1};
        expect(() => EqSettings.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('throws when a field has the wrong type', () {
        final json = {'bass': '1', 'mid': 1, 'treble': 1};
        expect(() => EqSettings.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      late Map<String, dynamic> json;

      setUp(() {
        json = eqSettings.toJson();
      });

      test('includes the correct event type key', () {
        expect(json['type'], equals(kEqEvent));
      });

      test('serialises bass correctly', () {
        expect(json['bass'], equals(testBass));
      });

      test('serialises mid correctly', () {
        expect(json['mid'], equals(testMid));
      });

      test('serialises treble correctly', () {
        expect(json['treble'], equals(testTreble));
      });

      test('contains exactly four keys', () {
        expect(json.keys, containsAll(['type', 'bass', 'mid', 'treble']));
        expect(json.length, equals(4));
      });
    });

    group('fromJson → toJson round-trip', () {
      test('preserves all fields after a round-trip', () {
        final original = eqSettings.toJson();
        final restored = EqSettings.fromJson(original);
        final result = restored.toJson();

        expect(result['bass'], equals(original['bass']));
        expect(result['mid'], equals(original['mid']));
        expect(result['treble'], equals(original['treble']));
        expect(result['type'], equals(kEqEvent));
      });
    });
  });
}
