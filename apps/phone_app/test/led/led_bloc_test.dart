import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/led/bloc/led_bloc.dart';
import 'package:bt_speaker_core/led_command.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements WebSocketClient {}

void main() {
  group('LedBloc', () {
    late _MockClient client;

    setUp(() {
      client = _MockClient();
      when(() => client.send(any())).thenReturn(null);
    });

    blocTest<LedBloc, LedState>(
      'emits LedCurrent with new values and sends to client',
      build: () => LedBloc(client: client),
      act: (bloc) => bloc.add(
        LedCommandChanged(
          mode: LedMode.breathe,
          r: 100,
          g: 200,
          b: 50,
          brightness: 200,
        ),
      ),
      expect: () => [
        isA<LedCurrent>()
            .having((s) => s.mode, 'mode', LedMode.breathe)
            .having((s) => s.r, 'r', 100)
            .having((s) => s.g, 'g', 200)
            .having((s) => s.b, 'b', 50)
            .having((s) => s.brightness, 'brightness', 200),
      ],
      verify: (_) => verify(() => client.send(any())).called(1),
    );

    test('initial state is white static at half brightness', () {
      final bloc = LedBloc(client: client);
      final s = bloc.state as LedCurrent;
      expect(s.mode, LedMode.static);
      expect(s.r, 255);
      expect(s.g, 255);
      expect(s.b, 255);
      expect(s.brightness, 128);
      bloc.close();
    });
  });
}
