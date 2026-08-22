import 'package:flutter_test/flutter_test.dart';
import 'package:JapAura/app.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const NamJapApp());
  });
}
