part of 'led_bloc.dart';

/// Base class for all LED states.
sealed class LedState extends Equatable {
  const LedState();
}

/// Current LED control values.
final class LedCurrent extends LedState {
  /// Creates the current LED state with sensible defaults
  /// (white static at half brightness).
  const LedCurrent({
    this.mode = LedMode.static,
    this.r = 255,
    this.g = 255,
    this.b = 255,
    this.brightness = 128,
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

  @override
  List<Object?> get props => [mode, r, g, b, brightness];
}
