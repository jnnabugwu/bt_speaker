import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bt_speaker_core/led_command.dart';

/// Interface for driving the WS2812B LED ring.
abstract class LedDriver {
  /// Starts the driver, preparing it to accept [apply] calls.
  Future<void> start(String scriptPath);

  /// Forwards [command] to the LED hardware.
  void apply(LedCommand command);

  /// Releases resources and shuts down the driver.
  Future<void> dispose();
}

/// Drives the ring by managing a Python daemon subprocess over SPI.
///
/// The daemon reads JSON [LedCommand] payloads from stdin and controls the
/// ring via SPI. Call [start] once, then [apply] on every command change,
/// and [dispose] on shutdown.
class ProcessLedDriver implements LedDriver {
  Process? _process;

  @override
  Future<void> start(String scriptPath) async {
    _process = await Process.start('python3', [scriptPath]);
    // Drain stderr so the OS buffer never stalls the subprocess.
    // drain<void> avoids a TypeError: drain completes with null which is
    // assignable to void but not to a concrete type like List<int>.
    unawaited(_process!.stderr.drain<void>());
  }

  @override
  void apply(LedCommand command) {
    if (_process == null) return;
    _process!.stdin.writeln(jsonEncode(command.toJson()));
  }

  @override
  Future<void> dispose() async {
    await _process?.stdin.close();
    _process?.kill();
    _process = null;
  }
}
