import 'package:dime/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(App());

    // await Future calls
    await tester.pump(Duration(seconds: 1));

    expect(find.text('DiMe'), findsOneWidget);
  });
}
