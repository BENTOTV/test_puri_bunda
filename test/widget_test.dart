import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medref/app.dart';

void main() {
  testWidgets('MedRefApp builds without crashing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MedRefApp(prefs: prefs));
    await tester.pump();

    expect(find.byType(MedRefApp), findsOneWidget);
  });
}
