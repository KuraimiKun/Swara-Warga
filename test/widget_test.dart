// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:swarawarga/main.dart';

void main() {
  testWidgets('SuaraWarga app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SuaraWargaApp());

    // Verify that the app loads (this is a basic smoke test)
    expect(find.text('SuaraWarga'), findsAny);
  });
}
