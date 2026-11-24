import 'dart:convert';

import 'package:hatbodol/Services/AppLog.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  final String baseUrl;
  final http.Client _httpClient;

  ApiServices({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final Map<String, String> _defaultHeader = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  Future<dynamic> get(String endpoints, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'GET');
    final response = await _httpClient.get(url, headers: {..._defaultHeader, ...?headers});
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> post(String endpoints, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'POST', body: body);
    final encodedBody = body != null ? jsonEncode(body) : null;

    late final http.Response response;
    try {
      response = await _httpClient
          .post(url, headers: {..._defaultHeader, ...?headers}, body: encodedBody)
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      AppLog.error(endpoints, e.toString());
      rethrow;
    }
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> delete(String endpoints, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'DELETE', body: body);
    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.delete(url, headers: {..._defaultHeader, ...?headers}, body: encodedBody);
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> patch(String endpoints, {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'PATCH', body: body);
    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.patch(url, headers: {..._defaultHeader, ...?headers}, body: encodedBody);
    return _handleResponse(response, url, endpoints);
  }

  Future<dynamic> postFormData(String endpoints, {Map<String, String>? headers, required Map<String, String> fields}) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'POST [form-data]', body: fields);
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Accept': 'application/json', ...?headers});
    request.fields.addAll(fields);
    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response, url, endpoints);
  }

  /// ফাইলসহ POST (multipart/form-data), ছবি আপলোডের জন্য
  Future<dynamic> postMultipart(
      String endpoints, {
        Map<String, String>? headers,
        Map<String, String> fields = const {},
        String? fileField,
        String? filePath,
      }) async {
    final url = Uri.parse('$baseUrl$endpoints');
    AppLog.request(endpoints, method: 'POST [multipart]', body: {
      ...fields,
      if (filePath != null) (fileField ?? 'file'): filePath,
    });

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Accept': 'application/json', ...?headers});
    request.fields.addAll(fields);
    if (fileField != null && filePath != null) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    // নেটওয়ার্কের অংশটুকুই শুধু try এর ভেতরে
    late final http.Response response;
    try {
      final streamed =
      await _httpClient.send(request).timeout(const Duration(seconds: 60));
      response = await http.Response.fromStream(streamed);
    } catch (e) {
      AppLog.error(endpoints, e.toString()); // নেটওয়ার্ক/টাইমআউট error লগে আসবে
      rethrow;
    }

    // সার্ভারের error (৪xx/৫xx) এখানে আগের মতোই ছোড়া হবে
    return _handleResponse(response, url, endpoints);
  }

  dynamic _handleResponse(http.Response response, Uri url, String endpoint) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      AppLog.response(endpoint, decoded);
      return decoded;
    }
    AppLog.error(endpoint, response.body, statusCode: response.statusCode);
    throw ApiException(
      message: "Request failed",
      statusCode: response.statusCode,
      uri: url,
      body: response.body,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Uri uri;
  final String? body;

  ApiException({
    required this.message,
    required this.statusCode,
    required this.uri,
    this.body,
  });

  @override
  String toString() =>
      "ApiException(status code: $statusCode, uri: $uri, message: $message, body: $body)";
}