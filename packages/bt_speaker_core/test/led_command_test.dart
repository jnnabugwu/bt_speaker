import 'package:bt_speaker_core/led_command.dart';
import 'package:bt_speaker_core/websocket_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LedModeX.wireName', () {
    test('maps static to "static"', () {
      expect(LedMode.static.wireName, equals('static'));
    });

    test('maps beatSync to "beat_sync"', () {
      expect(LedMode.beatSync.wireName, equals('beat_sync'));
    });

    test('maps breathe to "breathe"', () {
      expect(LedMode.breathe.wireName, equals('breathe'));
    });

    test('maps off to "off"', () {
      expect(LedMode.off.wireName, equals('off'));
    });
  });

  group('LedCommand', () {
    const ledCommand = LedCommand(
      mode: LedMode.breathe,
      r: 10,
      g: 20,
      b: 30,
      brightness: 200,
    );

    group('constructor', () {
      test('assigns mode correctly', () {
        expect(ledCommand.mode, equals(LedMode.breathe));
      });

      test('assigns color channels correctly', () {
        expect(ledCommand.r, equals(10));
        expect(ledCommand.g, equals(20));
        expect(ledCommand.b, equals(30));
      });

      test('assigns brightness correctly', () {
        expect(ledCommand.brightness, equals(200));
      });
    });

    group('fromJson', () {
      test('parses every LedMode wire name back to its enum value', () {
        for (final mode in LedMode.values) {
          final json = {
            'mode': mode.wireName,
            'r': 1,
            'g': 2,
            'b': 3,
            'brightness': 4,
          };
          expect(LedCommand.fromJson(json).mode, equals(mode));
        }
      });

      test('parses color and brightness fields from JSON', () {
        final json = {
          'mode': 'static',
          'r': 255,
          'g': 128,
          'b': 0,
          'brightness': 64,
        };
        final result = LedCommand.fromJson(json);

        expect(result.r, equals(255));
        expect(result.g, equals(128));
        expect(result.b, equals(0));
        expect(result.brightness, equals(64));
      });

      test('throws when mode is not a recognised wire name', () {
        final json = {
          'mode': 'sparkle',
          'r': 1,
          'g': 1,
          'b': 1,
          'brightness': 1,
        };
        expect(() => LedCommand.fromJson(json), throwsA(isA<StateError>()));
      });

      test('throws when a color field has the wrong type', () {
        final json = {
          'mode': 'static',
          'r': '255',
          'g': 1,
          'b': 1,
          'brightness': 1,
        };
        expect(() => LedCommand.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toJson', () {
      late Map<String, dynamic> json;

      setUp(() {
        json = ledCommand.toJson();
      });

      test('includes the correct event type key', () {
        expect(json['type'], equals(kLedEvent));
      });

      test('serialises the mode as its wire name, not the enum name', () {
        expect(json['mode'], equals('breathe'));
      });

      test('serialises color and brightness correctly', () {
        expect(json['r'], equals(10));
        expect(json['g'], equals(20));
        expect(json['b'], equals(30));
        expect(json['brightness'], equals(200));
      });

      test('contains exactly six keys', () {
        expect(
          json.keys,
          containsAll(['type', 'mode', 'r', 'g', 'b', 'brightness']),
        );
        expect(json.length, equals(6));
      });
    });

    group('fromJson → toJson round-trip', () {
      test('preserves all fields after a round-trip', () {
        final original = ledCommand.toJson();
        final restored = LedCommand.fromJson(original);
        final result = restored.toJson();

        expect(result, equals(original));
      });
    });
  });
}
