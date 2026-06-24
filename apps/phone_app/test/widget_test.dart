import 'package:bt_speaker/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts and shows connection screen', (tester) async {
    await tester.pumpWidget(const PhoneApp());

    expect(find.text('BT Speaker'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
