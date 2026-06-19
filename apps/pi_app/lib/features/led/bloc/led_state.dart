part of 'led_bloc.dart';

///All states the [LedBloc] can emit
sealed class LedState extends Equatable {
  const LedState();
}

///Not listening for LED commands
final class LedIdle extends LedState {
  ///Creates a [LedIdle] state
  const LedIdle();

  @override
  List<Object?> get props => [];
}

///Actively receiving LED commands from the phone
final class LedActive extends LedState {
  ///Creates a [LedActive] state with the given [command]
  const LedActive(this.command);

  ///The most recently received LED command
  final LedCommand command;

  @override
  List<Object?> get props => [command];
}
