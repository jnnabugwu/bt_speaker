import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bt_speaker_core/led_command.dart';

/// Drives the WS2812B LED ring by managing a Python daemon subprocess.
///
/// The daemon reads JSON [LedCommand] payloads from stdin and controls the
/// ring via SPI. Call [start] once, then [apply] on every command change,
/// and [dispose] on shutdown.
class LedDriver {
  Process? _process;

  /// Spawns the LED daemon at [scriptPath].
  Future<void> start(String scriptPath) async {
    _process = await Process.start('python3', [scriptPath]);
    // Drain stderr so the OS buffer never stalls the subprocess.
    unawaited(_process!.stderr.drain<List<int>>());
  }

  /// Forwards [command] to the daemon via stdin.
  void apply(LedCommand command) {
    if (_process == null) return;
    _process!.stdin.writeln(jsonEncode(command.toJson()));
  }

  /// Closes stdin and terminates the daemon process.
  Future<void> dispose() async {
    await _process?.stdin.close();
    _process?.kill();
    _process = null;
  }
}
