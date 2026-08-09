import 'package:flutter_test/flutter_test.dart';

import 'package:qtcloud_econ_studio/main.dart';

void main() {
  testWidgets('量潮经济云壳可渲染机制设计页', (WidgetTester tester) async {
    await tester.pumpWidget(const EconApp());
    await tester.pumpAndSettle();
    expect(find.text('机制设计'), findsOneWidget);
    expect(find.text('招聘博弈机制'), findsOneWidget);
  });
}
