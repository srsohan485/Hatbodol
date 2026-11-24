import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:hatbodol/Services/ApiService.dart';
import 'package:http/http.dart' as http;

String apiErrorMessage(
    Object e, {
      String fallback = 'Something went wrong. Please try again.',
    }) {
  if (e is ApiException) {
    try {
      final msg = _extract(jsonDecode(e.body ?? ''));
      if (msg != null && msg.trim().isNotEmpty) return msg;
    } catch (_) {}
    if (e.statusCode >= 500) return 'Server error. Please try again later.';
    return fallback;
  }
  if (e is SocketException || e is http.ClientException) {
    return 'Cannot reach the server. Check your connection.';
  }
  if (e is TimeoutException) return 'Request timed out. Try again.';
  return fallback;
}

String? _extract(dynamic d) {
  if (d is String) return d;
  if (d is List) {
    return d.map(_extract).whereType<String>().join('\n');
  }
  if (d is Map) {
    for (final k in ['message', 'detail', 'error']) {
      if (d[k] != null) return _extract(d[k]);
    }
    return d.values
        .map(_extract)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join('\n');
  }
  return null;
}