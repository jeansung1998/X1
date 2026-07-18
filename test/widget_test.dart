import 'package:flutter_test/flutter_test.dart';
import 'package:x1/main.dart';

void main() {
  testWidgets('X1 app test', (WidgetTester tester) async {
    await tester.pumpWidget(const X1App());
  });
}