part of 'eq_bloc.dart';

///All events the [EqBloc] can receive
sealed class EqEvent {}

///Starts listening to the WebSocket events stream for EQ settings
final class EqStarted extends EqEvent {}

///Stops listening and resets to idle
final class EqStopped extends EqEvent {}

///Internal — fired from the events stream; do not add externally
final class EqSettingsReceived extends EqEvent {
  ///Creates an [EqSettingsReceived] with the given [settings]
  EqSettingsReceived(this.settings);

  ///The equalizer settings payload
  final EqSettings settings;
}
