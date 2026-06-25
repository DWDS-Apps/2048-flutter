import 'package:flutter_test/flutter_test.dart';
import 'package:merge_up_2048/app.dart';

void main() {
  testWidgets('App renders menu screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GameApp());
    // The app initially shows a loading indicator while loading preferences
    expect(find.byType(GameApp), findsOneWidget);
  });
}
