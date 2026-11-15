import 'package:flutter_test/flutter_test.dart';
import 'package:smart_study_assistant/main.dart';

void main() {
  testWidgets('Myless app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartStudyAssistantApp());
    expect(find.text('Myless'), findsWidgets);
  });
}
