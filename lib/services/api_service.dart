import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/logger.dart';

/// Base HTTP client for all API calls to the eSIM Marketplace backend.
///
/// Provides:
/// - Automatic `X-Telegram-Data` authentication header injection.
/// - JSON request/response helpers.
/// - Centralized error handling and logging.
class ApiService {
  ApiService._();

  static final http.Client _client = http.Client();

  // ---------------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------------

  /// The Telegram initData string used for authentication.
  ///
  /// This should be set from `window.Telegram.WebApp.initData` (or the
  /// equivalent on non-web platforms) before any API calls are made.
  static String? _telegramData;

  /// Sets the Telegram initData that will be sent with every request.
  static void setTelegramData(String? data) {
    _telegramData = data;
  }

  // ---------------------------------------------------------------------------
  // HTTP METHODS
  // ---------------------------------------------------------------------------

  /// Performs a GET request to [endpoint].
  ///
  /// [queryParams] are appended as URL query parameters.
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    return _request('GET', endpoint, queryParams: queryParams);
  }

  /// Performs a POST request to [endpoint] with the given [body].
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return _request('POST', endpoint, body: body);
  }

  /// Performs a PUT request to [endpoint].
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return _request('PUT', endpoint, body: body);
  }

  /// Performs a DELETE request to [endpoint].
  static Future<http.Response> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }

  // ---------------------------------------------------------------------------
  // LOW-LEVEL
  // ---------------------------------------------------------------------------

  static Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
      queryParameters: queryParams,
    );

    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (_telegramData != null && _telegramData!.isNotEmpty) {
      headers[ApiConfig.telegramDataHeader] = _telegramData!;
    }

    AppLogger.debug('$method $uri');

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
    } catch (e, stack) {
      AppLogger.error('HTTP $method $uri failed', e, stack);
      rethrow;
    }

    // Log non-200 responses as warnings
    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppLogger.warn(
        'HTTP $method $uri → ${response.statusCode} ${response.reasonPhrase}',
      );
    }

    return response;
  }
}