import 'package:bloc_test/bloc_test.dart';
import 'package:bt_speaker/features/connection/data/websocket_client.dart';
import 'package:bt_speaker/features/eq/bloc/eq_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements WebSocketClient {}

void main() {
  group('EqBloc', () {
    late _MockClient client;

    setUp(() {
      client = _MockClient();
      when(() => client.send(any())).thenReturn(null);
    });

    blocTest<EqBloc, EqState>(
      'emits EqCurrent with new values and sends to client',
      build: () => EqBloc(client: client),
      act: (bloc) => bloc.add(
        EqSettingsChanged(bass: 3, mid: -1, treble: 6),
      ),
      expect: () => [
        isA<EqCurrent>()
            .having((s) => s.bass, 'bass', 3)
            .having((s) => s.mid, 'mid', -1)
            .having((s) => s.treble, 'treble', 6),
      ],
      verify: (_) => verify(() => client.send(any())).called(1),
    );

    test('initial state is flat EQ (all zeros)', () {
      final bloc = EqBloc(client: client);
      final s = bloc.state as EqCurrent;
      expect(s.bass, 0);
      expect(s.mid, 0);
      expect(s.treble, 0);
      bloc.close();
    });
  });
}
