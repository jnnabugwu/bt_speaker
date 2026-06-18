import 'package:bt_speaker_core/bt_speaker_core.dart';

///Sealed class representing all incoming websocket message types from the phone
sealed class WsEvent {}

///Wraps a [BeatData] payload received from the phone
final class BeatEvent extends WsEvent {
  ///Creates a [BeatEvent] with the given [data]
  BeatEvent(this.data);

  ///The beat data payload
  final BeatData data;
}

///Wraps a [LedCommand] payload received from the phone
final class LedEvent extends WsEvent {
  ///Creates a [LedEvent] with the given [data]
  LedEvent(this.data);

  ///The LED command payload
  final LedCommand data;
}

///Wraps an [EqSettings] payload received from the phone
final class EqEvent extends WsEvent {
  ///Creates an [EqEvent] with the given [data]
  EqEvent(this.data);

  ///The equalizer settings payload
  final EqSettings data;
}

///Wraps a [NowPlaying] payload received from the phone
final class NowPlayingEvent extends WsEvent {
  ///Creates a [NowPlayingEvent] with the given [data]
  NowPlayingEvent(this.data);

  ///The now playing payload
  final NowPlaying data;
}
