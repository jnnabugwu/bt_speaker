part of 'eq_bloc.dart';

///All states the [EqBloc] can emit
sealed class EqState extends Equatable {
  const EqState();
}

///Not listening for EQ settings
final class EqIdle extends EqState {
  ///Creates an [EqIdle] state
  const EqIdle();

  @override
  List<Object?> get props => [];
}

///Actively receiving EQ settings from the phone
final class EqActive extends EqState {
  ///Creates an [EqActive] state with the given [settings]
  const EqActive(this.settings);

  ///The most recently received EQ settings
  final EqSettings settings;

  @override
  List<Object?> get props => [settings];
}
