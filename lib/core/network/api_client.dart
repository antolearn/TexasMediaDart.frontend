import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

typedef AccessTokenProvider = Future<String?> Function();
typedef AccessTokenRefresher = Future<String?> Function();

class ApiClient {
  factory ApiClient({
    http.Client? client,
    String? baseUrl,
    AccessTokenProvider? accessTokenProvider,
    AccessTokenRefresher? accessTokenRefresher,
  }) {
    return ApiClient._(
      baseUrl ?? AppConfig.apiBaseUrl,
      accessTokenProvider,
      accessTokenRefresher,
      client: client,
    );
  }

  ApiClient._(
    this._baseUrl,
    this._accessTokenProvider,
    this._accessTokenRefresher, {
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl;

  final AccessTokenProvider? _accessTokenProvider;
  final AccessTokenRefresher? _accessTokenRefresher;

  Future<String?>? _refreshFuture;

  Uri _buildUri(String endpoint, {Map<String, String>? queryParameters}) {
    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;

    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    final uri = Uri.parse('$normalizedBaseUrl$normalizedEndpoint');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...queryParameters},
    );
  }

  Map<String, String> _defaultHeaders() {
    return {'Accept': 'application/json', 'Content-Type': 'application/json'};
  }

  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? headers,
    bool authenticated = false,
  }) async {
    final result = {..._defaultHeaders(), ...?headers};

    if (authenticated && _accessTokenProvider != null) {
      final accessToken = await _accessTokenProvider();

      if (accessToken != null && accessToken.isNotEmpty) {
        result['Authorization'] = 'Bearer $accessToken';
      }
    }

    return result;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _execute(
      endpoint: endpoint,
      queryParameters: queryParameters,
      authenticated: authenticated,
      request: (uri, requestHeaders) {
        return _client.get(uri, headers: requestHeaders);
      },
      headers: headers,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _execute(
      endpoint: endpoint,
      queryParameters: queryParameters,
      authenticated: authenticated,
      request: (uri, requestHeaders) {
        return _client.post(
          uri,
          headers: requestHeaders,
          body: body == null ? null : jsonEncode(body),
        );
      },
      headers: headers,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _execute(
      endpoint: endpoint,
      queryParameters: queryParameters,
      authenticated: authenticated,
      request: (uri, requestHeaders) {
        return _client.put(
          uri,
          headers: requestHeaders,
          body: body == null ? null : jsonEncode(body),
        );
      },
      headers: headers,
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _execute(
      endpoint: endpoint,
      queryParameters: queryParameters,
      authenticated: authenticated,
      request: (uri, requestHeaders) {
        return _client.patch(
          uri,
          headers: requestHeaders,
          body: body == null ? null : jsonEncode(body),
        );
      },
      headers: headers,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool authenticated = false,
  }) async {
    return _execute(
      endpoint: endpoint,
      queryParameters: queryParameters,
      authenticated: authenticated,
      request: (uri, requestHeaders) {
        return _client.delete(
          uri,
          headers: requestHeaders,
          body: body == null ? null : jsonEncode(body),
        );
      },
      headers: headers,
    );
  }

  Future<dynamic> _execute({
    required String endpoint,
    Map<String, String>? queryParameters,
    required bool authenticated,
    required Future<http.Response> Function(
      Uri uri,
      Map<String, String> headers,
    )
    request,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParameters: queryParameters);

    try {
      var requestHeaders = await _buildHeaders(
        headers: headers,
        authenticated: authenticated,
      );

      var response = await request(uri, requestHeaders);

      if (response.statusCode == 401 &&
          authenticated &&
          _accessTokenRefresher != null) {
        final refreshedAccessToken = await _refreshAccessToken();

        if (refreshedAccessToken != null && refreshedAccessToken.isNotEmpty) {
          requestHeaders = await _buildHeaders(
            headers: headers,
            authenticated: true,
          );

          response = await request(uri, requestHeaders);
        }
      }

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unable to connect to API: $error');
    }
  }

  Future<String?> _refreshAccessToken() async {
    final existingRefresh = _refreshFuture;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    final refresher = _accessTokenRefresher;

    if (refresher == null) {
      return null;
    }

    final refreshFuture = refresher();

    _refreshFuture = refreshFuture;

    try {
      return await refreshFuture;
    } finally {
      _refreshFuture = null;
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
