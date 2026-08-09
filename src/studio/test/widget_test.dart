import 'package:flutter_test/flutter_test.dart';

import 'package:qtcloud_econ_studio/main.dart';

void main() {
  testWidgets('量潮经济云壳可渲染', (WidgetTester tester) async {
    await tester.pumpWidget(const EconApp());
    expect(find.text('量潮经济云'), findsOneWidget);
  });
}
