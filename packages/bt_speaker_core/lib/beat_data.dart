import 'package:bt_speaker_core/websocket_events.dart';

///BeatData is the information for the beat that we get from the current
///playing song
class BeatData {
  /// Creates beat analysis data from the current playing song.
  const BeatData({
    required this.bpm,
    required this.intensity,
    required this.fftBars,
  });

  /// Creates beat analysis data from a JSON map.
  factory BeatData.fromJson(Map<String, dynamic> json) {
    return BeatData(
      bpm: json['bpm'] as int,
      intensity: json['intensity'] as double,
      fftBars: (json['fft_bars'] as List).cast<double>(),
    );
  }

  ///the beats per mintue
  final int bpm;

  ///the intensity level
  final double intensity;

  /// what will be used to display the fftbars
  final List<double> fftBars;

  /// Converts the beat data to a JSON map.
  Map<String, dynamic> toJson() => {
    'type': kBeatEvent,
    'bpm': bpm,
    'intensity': intensity,
    'fft_bars': fftBars,
  };
}
