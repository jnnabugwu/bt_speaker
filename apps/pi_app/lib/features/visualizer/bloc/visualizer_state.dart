part of 'visualizer_bloc.dart';

///All states the [VisualizerBloc] can emit
sealed class VisualizerState extends Equatable {
  const VisualizerState();
}

///Not listening for beat data
final class VisualizerIdle extends VisualizerState {
  ///Creates a [VisualizerIdle] state
  const VisualizerIdle();

  @override
  List<Object?> get props => [];
}

///Actively receiving beat data from the phone
final class VisualizerActive extends VisualizerState {
  ///Creates a [VisualizerActive] state with the given [data]
  const VisualizerActive(this.data);

  ///The most recently received beat data
  final BeatData data;

  @override
  List<Object?> get props => [data];
}
