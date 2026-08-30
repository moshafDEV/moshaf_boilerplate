import 'package:dio/dio.dart';

const _sensitiveHeaderKeys = {'authorization', 'cookie', 'set-cookie'};
const _sensitiveBodyKeys = {
  'password',
  'token',
  'access_token',
  'refresh_token',
  'secret',
};

/// Masks known-sensitive header values. Keeps a scheme prefix like "Bearer"
/// visible (useful context when reading logs) but never the token itself.
Map<String, dynamic> maskHeaders(Map<String, dynamic> headers) {
  return headers.map((key, value) {
    if (!_sensitiveHeaderKeys.contains(key.toLowerCase())) {
      return MapEntry(key, value);
    }
    final parts = value.toString().split(' ');
    final masked = parts.length > 1 ? '${parts.first} ****' : '****';
    return MapEntry(key, masked);
  });
}

/// Recursively masks known-sensitive keys in a request/response body. Only
/// Map/List bodies are inspected — non-JSON bodies (e.g. raw strings,
/// FormData, bytes) pass through unmasked, since there's no safe way to
/// find a "password" field inside them.
dynamic maskBody(dynamic body) {
  if (body is Map) {
    return body.map((key, value) {
      if (_sensitiveBodyKeys.contains(key.toString().toLowerCase())) {
        return MapEntry(key, '****');
      }
      return MapEntry(key, maskBody(value));
    });
  }
  if (body is List) return body.map(maskBody).toList();
  return body;
}

/// One recorded HTTP call. Bodies/headers are masked at construction time —
/// nothing sensitive is ever held in memory here, let alone stored or
/// displayed.
class ApiLogEntry {
  final String method;
  final String url;
  final Map<String, dynamic> requestHeaders;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final String? errorMessage;
  final Duration duration;
  final DateTime timestamp;

  const ApiLogEntry({
    required this.method,
    required this.url,
    required this.requestHeaders,
    required this.requestBody,
    required this.statusCode,
    required this.responseBody,
    required this.errorMessage,
    required this.duration,
    required this.timestamp,
  });

  bool get isError =>
      errorMessage != null || (statusCode != null && statusCode! >= 400);

  factory ApiLogEntry.from({
    required RequestOptions options,
    required DateTime startedAt,
    int? statusCode,
    dynamic responseBody,
    String? errorMessage,
  }) {
    return ApiLogEntry(
      method: options.method,
      url: options.uri.toString(),
      requestHeaders: maskHeaders(Map<String, dynamic>.from(options.headers)),
      requestBody: maskBody(options.data),
      statusCode: statusCode,
      responseBody: maskBody(responseBody),
      errorMessage: errorMessage,
      duration: DateTime.now().difference(startedAt),
      timestamp: startedAt,
    );
  }
}
