import 'package:bt_speaker_core/websocket_events.dart';

///The mode of the led
enum LedMode {
  ///The mode of the led is static
  static,

  ///The mode of the led is beat sync
  beatSync,

  ///The mode of the led is breathe
  breathe,

  ///The mode of the led is off
  off,
}

///Extension to get the wire name of the led mode
extension LedModeX on LedMode {
  ///Get the wire name of the led mode
  String get wireName => switch (this) {
    LedMode.static => 'static',
    LedMode.beatSync => 'beat_sync',
    LedMode.breathe => 'breathe',
    LedMode.off => 'off',
  };
}

///LedCommand is the command that we send to the pi to control the led
///it contains the mode, the color, and the brightness
class LedCommand {
  /// Creates a led command from the current playing song.
  const LedCommand({
    required this.mode,
    required this.r,
    required this.g,
    required this.b,
    required this.brightness,
  });

  /// Creates a led command from a JSON map.
  factory LedCommand.fromJson(Map<String, dynamic> json) {
    return LedCommand(
      mode: LedMode.values.firstWhere(
        (e) => e.wireName == json['mode'] as String,
      ),
      r: json['r'] as int,
      g: json['g'] as int,
      b: json['b'] as int,
      brightness: json['brightness'] as int,
    );
  }

  ///the mode of the led
  final LedMode mode;

  ///the amount of red
  final int r;

  ///the amount of green
  final int g;

  ///the amount of blue
  final int b;

  ///the brightness of the led
  final int brightness;

  /// Converts the led command to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': kLedEvent,
    'mode': mode.wireName,
    'r': r,
    'g': g,
    'b': b,
    'brightness': brightness,
  };
}
