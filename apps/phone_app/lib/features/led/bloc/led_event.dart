part of 'led_bloc.dart';

/// Base class for all LED events.
sealed class LedEvent {}

/// Dispatched when the user changes any LED control.
final class LedCommandChanged extends LedEvent {
  /// Creates an LED command change.
  LedCommandChanged({
    required this.mode,
    required this.r,
    required this.g,
    required this.b,
    required this.brightness,
  });

  /// LED animation mode.
  final LedMode mode;

  /// Red channel (0–255).
  final int r;

  /// Green channel (0–255).
  final int g;

  /// Blue channel (0–255).
  final int b;

  /// Overall brightness (0–255).
  final int brightness;
}
