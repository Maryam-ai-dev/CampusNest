import 'package:flutter_test/flutter_test.dart';

import 'package:campusnest/app.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusNestApp());

    expect(find.text('CampusNest - Firebase connected'), findsOneWidget);
  });
}
