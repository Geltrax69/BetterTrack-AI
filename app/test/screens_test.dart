// Buildability smoke tests: render every screen at an iPhone-sized surface and
// assert the key widgets are present (screen builds, no crash, no missing dep).
// Cosmetic fake-font overflows are filtered (see test_helpers.dart). On-device
// layout is verified separately via the simulator run + screenshots.
import 'package:bettertrack/data/mock_data.dart';
import 'package:bettertrack/screens/ai_chat_screen.dart';
import 'package:bettertrack/screens/analytics_screen.dart';
import 'package:bettertrack/screens/group_details_screen.dart';
import 'package:bettertrack/screens/groups_screen.dart';
import 'package:bettertrack/screens/home_shell.dart';
import 'package:bettertrack/screens/profile_screen.dart';
import 'package:bettertrack/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

// Screens like Dashboard/Profile render inside HomeShell's Scaffold on-device,
// so provide one here too (gives ListTile its required Material ancestor).
Widget _host(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

Future<void> _pumpPhone(WidgetTester tester, Widget screen) async {
  ignoreOverflowErrors();
  useMockBackend(); // canned API responses, no real network
  tester.view.physicalSize = const Size(1170, 2532); // iPhone 16e
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_host(screen));
  await tester.pump(const Duration(milliseconds: 350)); // settle data/charts/tabs
}

void main() {
  testWidgets('HomeShell + Dashboard', (tester) async {
    await _pumpPhone(tester, const HomeShell());
    expect(find.text('Hello, Sam'), findsOneWidget);
    expect(find.text('Budgets'), findsOneWidget);
  });

  testWidgets('Groups screen', (tester) async {
    await _pumpPhone(tester, const GroupsScreen());
    expect(find.text('Goa Trip'), findsOneWidget);
  });

  testWidgets('Analytics screen', (tester) async {
    await _pumpPhone(tester, const AnalyticsScreen());
    expect(find.text('Analytics'), findsOneWidget);
  });

  testWidgets('Profile screen', (tester) async {
    await _pumpPhone(tester, const ProfileScreen());
    expect(find.text('Sam Mehta'), findsOneWidget);
  });

  testWidgets('Group details (5 tabs)', (tester) async {
    await _pumpPhone(tester, GroupDetailsScreen(group: MockData.groups.first));
    expect(find.text('Overview'), findsOneWidget);
  });

  testWidgets('AI chat screen', (tester) async {
    await _pumpPhone(tester, const AiChatScreen());
    expect(find.text('BetterTrack AI'), findsWidgets);
  });
}
