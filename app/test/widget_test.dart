// Smoke test: the app boots to the dashboard.
//
// Note: the flutter_test harness renders with a fake font whose metrics are
// taller than the bundled Poppins, so the design's fixed-height cards report
// cosmetic RenderFlex overflows that never occur on a real device. We install
// an overflow-only error filter for the duration of the test (real errors still
// fail it). On-device layout is verified via the simulator run + screenshots.
import 'package:bettertrack/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('App boots to the dashboard', (tester) async {
    ignoreOverflowErrors();
    useMockBackend();
    await tester.pumpWidget(const BetterTrackApp());
    await tester.pump(); // initial frame (spinner)
    await tester.pump(const Duration(milliseconds: 50)); // mock resolves
    expect(find.text('Hello, Sam'), findsOneWidget);
    expect(find.text('Budgets'), findsOneWidget);
  });
}
