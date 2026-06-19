import 'package:flutter_test/flutter_test.dart';
import 'package:game2048/app.dart';

void main() {
  testWidgets('App renders menu screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GameApp());
    expect(find.text('2048'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });
}
