import 'dart:convert';

import 'package:bettertrack/services/api_client.dart';
import 'package:bettertrack/services/repository.dart';
import 'package:bettertrack/services/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Initialises [AppSettings] with mock prefs. Pass loggedIn:true so the AuthGate
/// shows the app (not the login screen) during widget tests.
Future<void> useTestSettings({bool loggedIn = false}) async {
  SharedPreferences.setMockInitialValues(
      loggedIn ? {'token': 'test-token'} : {});
  await AppSettings.instance.init();
}

/// Installs a [Repository] backed by a MockClient returning canned JSON, so
/// screens load instantly with no real network (no sockets, no pending timers).
void useMockBackend() {
  final mock = MockClient((req) async {
    final path = req.url.path;
    final isPost = req.method == 'POST';
    Object body;
    if (path.endsWith('/summary')) {
      body = {'owed': 6200, 'owing': 1800, 'net': 4400};
    } else if (path.endsWith('/budgets')) {
      body = [
        {'name': 'Food', 'spent': 8200, 'limit': 10000},
        {'name': 'Travel', 'spent': 14500, 'limit': 12000},
      ];
    } else if (path.endsWith('/activity')) {
      body = [
        {'type': 'expense', 'title': 'Dinner at Olive',
         'subtitle': 'Sam paid ₹2,400', 'time': '2h'},
      ];
    } else if (path.endsWith('/groups')) {
      // POST returns the created group (object); GET returns the list.
      body = isPost
          ? {'id': 'gNew', 'name': 'New Group', 'member_count': 1,
             'currency': '₹', 'outstanding': 0, 'last_activity': 'Created'}
          : [
              {'id': 'g1', 'name': 'Goa Trip', 'member_count': 5,
               'currency': '₹', 'outstanding': 6200,
               'last_activity': 'Dinner · 2h'},
            ];
    } else if (path.contains('/expenses')) {
      body = isPost
          ? {'id': 'eNew', 'name': 'New', 'category': 'food', 'amount': 100,
             'payer': 'You', 'date': '2026-06-13T00:00:00', 'settled': false}
          : [
              {'id': 'e1', 'name': 'Dinner at Olive', 'category': 'food',
               'amount': 2400, 'payer': 'Sam', 'date': '2026-06-13T00:00:00',
               'settled': false},
            ];
    } else if (path.endsWith('/ai/chat')) {
      body = {'reply': 'Sure!', 'used_ai': false};
    } else {
      body = {};
    }
    return http.Response(jsonEncode(body), 200,
        headers: {'content-type': 'application/json'});
  });
  Repository.instance = Repository(client: ApiClient(client: mock));
}

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
