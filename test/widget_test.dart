import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fixit_gh/app/app.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FixItGHApp()),
    );

    expect(find.text('FixIt GH'), findsOneWidget);

    // Splash screen navigates away after a 3s timer; flush it so the test
    // doesn't tear down with a pending Timer.
    await tester.pump(const Duration(seconds: 3));
  });
}
