import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bt_speaker_core/beat_data.dart';

/// Interface for receiving live [BeatData] from an audio analysis source.
abstract class AudioDriver {
  /// Starts the driver, connecting it to the audio source at [scriptPath].
  Future<void> start(String scriptPath);

  /// Broadcast stream of [BeatData] frames emitted at ~30 fps.
  Stream<BeatData> get beats;

  /// Releases all resources and stops the audio source.
  Future<void> dispose();
}

/// Drives audio analysis by spawning `fft_daemon.py` as a subprocess.
///
/// The daemon reads ALSA loopback audio, computes FFT at 30 fps, and writes
/// [BeatData]-compatible JSON lines to stdout. This class reads those lines
/// and exposes them as a [Stream<BeatData>].
class FftProcessDriver implements AudioDriver {
  Process? _process;
  final _controller = StreamController<BeatData>.broadcast();

  @override
  Future<void> start(String scriptPath) async {
    _process = await Process.start('python3', [scriptPath]);
    unawaited(_process!.stderr.drain<void>());
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      try {
        _controller.add(
          BeatData.fromJson(jsonDecode(line) as Map<String, dynamic>),
        );
      } catch (_) {}
    });
  }

  @override
  Stream<BeatData> get beats => _controller.stream;

  @override
  Future<void> dispose() async {
    _process?.kill();
    _process = null;
    await _controller.close();
  }
}
