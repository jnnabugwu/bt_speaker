import 'package:bt_speaker_core/websocket_events.dart';

///EqSettings is the settings for the equalizer
class EqSettings {
  /// Creates equalizer settings from a JSON map.
  const EqSettings({
    required this.bass,
    required this.mid,
    required this.treble,
  });

  /// Creates equalizer settings from a JSON map.
  factory EqSettings.fromJson(Map<String, dynamic> json) {
    return EqSettings(
      bass: json['bass'] as int,
      mid: json['mid'] as int,
      treble: json['treble'] as int,
    );
  }

  ///the bass setting
  final int bass;

  ///the mid setting
  final int mid;

  ///the treble setting
  final int treble;

  /// Converts the equalizer settings to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': kEqEvent,
    'bass': bass,
    'mid': mid,
    'treble': treble,
  };
}
