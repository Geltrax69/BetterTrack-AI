import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide user settings, persisted with SharedPreferences. A global
/// [ChangeNotifier] singleton so any screen can read and react to changes.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  // Nullable so reads return defaults before init() (e.g. in widget tests).
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Profile ──
  String get name => _prefs?.getString('name') ?? 'Sam Mehta';
  String get email => _prefs?.getString('email') ?? 'sam@bettertrack.ai';
  Future<void> setProfile(String name, String email) async {
    await _prefs?.setString('name', name);
    await _prefs?.setString('email', email);
    notifyListeners();
  }

  // ── Currency ──
  static const currencies = {
    'INR': '₹',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
  };
  String get currencyCode => _prefs?.getString('currency') ?? 'INR';
  String get currencySymbol => currencies[currencyCode] ?? '₹';
  Future<void> setCurrency(String code) async {
    await _prefs?.setString('currency', code);
    notifyListeners();
  }

  // ── Generic boolean flags (notifications, AI, privacy) ──
  bool flag(String key, {bool fallback = true}) =>
      _prefs?.getBool(key) ?? fallback;
  Future<void> setFlag(String key, bool value) async {
    await _prefs?.setBool(key, value);
    notifyListeners();
  }

  // ── Payment methods ──
  List<String> get paymentMethods =>
      _prefs?.getStringList('payments') ??
      ['UPI · sam@okaxis', 'Visa •••• 6411'];
  Future<void> addPayment(String method) async {
    final list = [...paymentMethods, method];
    await _prefs?.setStringList('payments', list);
    notifyListeners();
  }

  Future<void> removePayment(String method) async {
    final list = [...paymentMethods]..remove(method);
    await _prefs?.setStringList('payments', list);
    notifyListeners();
  }
}
