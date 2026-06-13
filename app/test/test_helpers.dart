import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Filters out *only* cosmetic "RenderFlex overflowed" errors caused by the
/// flutter_test fake font (taller than bundled Poppins). Any other framework
/// error is still surfaced and fails the test. Call at the top of a test body
/// so it overrides flutter_test's per-test handler; it auto-restores on teardown.
void ignoreOverflowErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final msg = details.exceptionAsString();
    if (msg.contains('A RenderFlex overflowed')) return; // swallow cosmetic
    (previous ?? FlutterError.presentError)(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}
