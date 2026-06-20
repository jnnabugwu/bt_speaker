import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_app/features/connections/bloc/connection_bloc.dart';
import 'package:pi_app/features/connections/data/websocket_server.dart';
import 'package:pi_app/main.dart';

void main() {
  testWidgets('App renders placeholder without crashing', (tester) async {
    // runAsync lets real IO run so server.start() can bind and server.stop()
    // can actually close it — without it Flutter's fake-async scheduler never
    // settles the background server loop.
    await tester.runAsync(() async {
      final server = WebSocketServer(port: 0);
      await tester.pumpWidget(MyApp(server: server));
      await tester.pump();
      expect(find.text('BT Speaker Pi'), findsOneWidget);
      await tester.element(find.byType(AppRoot)).read<ConnectionBloc>().close();
    });
  });
}
