part of 'visualizer_bloc.dart';

///All events the [VisualizerBloc] can receive
sealed class VisualizerEvent {}

///Starts listening to the WebSocket events stream for beat data
final class VisualizerStarted extends VisualizerEvent {}

///Stops listening and resets to idle
final class VisualizerStopped extends VisualizerEvent {}

///Internal — fired from the events stream; do not add externally
final class VisualizerBeatReceived extends VisualizerEvent {
  ///Creates a [VisualizerBeatReceived] with the given [data]
  VisualizerBeatReceived(this.data);

  ///The beat data payload
  final BeatData data;
}
