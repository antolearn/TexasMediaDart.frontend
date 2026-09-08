import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String endpoint) {
    final baseUrl = AppConfig.apiBaseUrl;

    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    return Uri.parse('$normalizedBaseUrl$normalizedEndpoint');
  }

  Map<String, String> _defaultHeaders() {
    return {'Accept': 'application/json', 'Content-Type': 'application/json'};
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = _buildUri(endpoint);

    try {
      final response = await _client.get(
        uri,
        headers: {..._defaultHeaders(), ...?headers},
      );

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to connect to API: $error');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(response),
    );
  }

  String _extractErrorMessage(http.Response response) {
    if (response.body.isEmpty) {
      return 'API request failed.';
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] != null) {
          return decoded['detail'].toString();
        }

        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }

        if (decoded['title'] != null) {
          return decoded['title'].toString();
        }
      }
    } catch (_) {
      // Response is not JSON.
    }

    return response.body;
  }

  void dispose() {
    _client.close();
  }
}
