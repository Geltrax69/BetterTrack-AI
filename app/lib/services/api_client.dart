import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Base URL of the FastAPI backend.
///
/// iOS Simulator & desktop reach the host via 127.0.0.1. For the Android
/// emulator use 10.0.2.2; for a physical device use your machine's LAN IP.
/// Override at build time with: --dart-define=API_BASE_URL=http://host:8000/api
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const Duration timeout = Duration(seconds: 10);
}

/// Friendly, user-facing failure with a [message] safe to show in the UI.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

/// Thin HTTP wrapper that returns decoded JSON and maps low-level failures
/// (no network, timeout, 5xx) onto [ApiException]s with readable messages.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<dynamic> get(String path) => _send(() => _client.get(_uri(path)));

  Future<dynamic> post(String path, {Object? body}) => _send(
        () => _client.post(
          _uri(path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body ?? {}),
        ),
      );

  Future<dynamic> _send(Future<http.Response> Function() run) async {
    try {
      final res = await run().timeout(ApiConfig.timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return res.body.isEmpty ? null : jsonDecode(res.body);
      }
      if (res.statusCode >= 500) {
        throw const ApiException('Server error. Please try again in a moment.');
      }
      // Surface a backend-provided detail when present.
      String detail = 'Request failed (${res.statusCode}).';
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['detail'] != null) detail = m['detail'].toString();
      } catch (_) {}
      throw ApiException(detail);
    } on SocketException {
      throw const ApiException(
          "Can't reach the server. Check your connection and that the backend is running.");
    } on TimeoutException {
      throw const ApiException('The server took too long to respond.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Something went wrong. Please try again.');
    }
  }

  void close() => _client.close();
}
