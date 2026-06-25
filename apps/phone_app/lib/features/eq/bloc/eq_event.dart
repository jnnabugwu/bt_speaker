part of 'eq_bloc.dart';

/// Base class for all EQ events.
sealed class EqEvent {}

/// Dispatched when the user moves an EQ slider.
final class EqSettingsChanged extends EqEvent {
  /// Creates an EQ settings change with [bass], [mid], and [treble] values
  /// in the range −12..+12.
  EqSettingsChanged({
    required this.bass,
    required this.mid,
    required this.treble,
  });

  /// Bass gain in dB (−12..+12).
  final int bass;

  /// Mid gain in dB (−12..+12).
  final int mid;

  /// Treble gain in dB (−12..+12).
  final int treble;
}
