part of 'eq_bloc.dart';

/// Base class for all EQ states.
sealed class EqState extends Equatable {
  const EqState();
}

/// Current EQ band values.
final class EqCurrent extends EqState {
  /// Creates the current EQ state. All bands default to 0 (flat).
  const EqCurrent({this.bass = 0, this.mid = 0, this.treble = 0});

  /// Bass gain in dB.
  final int bass;

  /// Mid gain in dB.
  final int mid;

  /// Treble gain in dB.
  final int treble;

  @override
  List<Object?> get props => [bass, mid, treble];
}
