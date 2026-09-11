import 'dart:convert';

import '../models/auth_tokens.dart';
import '../models/register_response.dart';
import '../models/user_profile.dart';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

class IdentityApiService {
  IdentityApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _buildUri(String path) {
    final baseUrl = AppConfig.identityApiBaseUrl;

    return Uri.parse('$baseUrl$path');
  }

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      _buildUri('/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    final json = _handleResponse(response);

    return RegisterResponse.fromJson(json);
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _buildUri('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final json = _handleResponse(response);

    return AuthTokens.fromJson(json);
  }

  Future<UserProfile> getMe({required String accessToken}) async {
    final response = await http.get(
      Uri.parse('${AppConfig.identityApiBaseUrl}/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw IdentityApiException(
      statusCode: response.statusCode,
      message: 'Unable to retrieve user profile.',
    );
  }

  Future<AuthTokens> refreshToken({required String refreshToken}) async {
    final response = await _client.post(
      _buildUri('/api/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final json = _handleResponse(response);

    return AuthTokens.fromJson(json);
  }

  Future<void> logout({required String refreshToken}) async {
    final response = await _client.post(
      _buildUri('/api/auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IdentityApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response),
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw IdentityApiException(
      statusCode: response.statusCode,
      message: _extractErrorMessage(response),
    );
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);

      if (json is Map<String, dynamic>) {
        return json['message']?.toString() ??
            json['detail']?.toString() ??
            json['title']?.toString() ??
            'Request failed.';
      }
    } catch (_) {
      // Ignore invalid JSON and fall back below.
    }

    return response.body.isNotEmpty
        ? response.body
        : 'Request failed with status ${response.statusCode}.';
  }

  void dispose() {
    _client.close();
  }
}

class IdentityApiException implements Exception {
  IdentityApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() {
    return 'IdentityApiException($statusCode): $message';
  }
}
