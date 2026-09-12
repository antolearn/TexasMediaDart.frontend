import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

import '../models/auth_tokens.dart';
import '../models/register_response.dart';
import '../models/user_profile.dart';

class IdentityApiService {
  IdentityApiService({ApiClient? apiClient})
    : _apiClient =
          apiClient ?? ApiClient(baseUrl: AppConfig.identityApiBaseUrl);

  final ApiClient _apiClient;

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        body: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response is! Map<String, dynamic>) {
        throw IdentityApiException(
          statusCode: null,
          message: 'Unexpected response format from registration endpoint.',
        );
      }

      return RegisterResponse.fromJson(response);
    } on ApiException catch (ex) {
      throw _toIdentityApiException(ex);
    }
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response is! Map<String, dynamic>) {
        throw IdentityApiException(
          statusCode: null,
          message: 'Unexpected response format from login endpoint.',
        );
      }

      return AuthTokens.fromJson(response);
    } on ApiException catch (ex) {
      throw _toIdentityApiException(ex);
    }
  }

  Future<UserProfile> getMe({required String accessToken}) async {
    try {
      final response = await _apiClient.get(
        '/api/auth/me',
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response is! Map<String, dynamic>) {
        throw IdentityApiException(
          statusCode: null,
          message: 'Unexpected response format from /api/auth/me.',
        );
      }

      return UserProfile.fromJson(response);
    } on ApiException catch (ex) {
      throw _toIdentityApiException(ex);
    }
  }

  Future<AuthTokens> refreshToken({required String refreshToken}) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      if (response is! Map<String, dynamic>) {
        throw IdentityApiException(
          statusCode: null,
          message: 'Unexpected response format from refresh endpoint.',
        );
      }

      return AuthTokens.fromJson(response);
    } on ApiException catch (ex) {
      throw _toIdentityApiException(ex);
    }
  }

  Future<void> logout({required String refreshToken}) async {
    try {
      await _apiClient.post(
        '/api/auth/logout',
        body: {'refreshToken': refreshToken},
      );
    } on ApiException catch (ex) {
      throw _toIdentityApiException(ex);
    }
  }

  IdentityApiException _toIdentityApiException(ApiException exception) {
    return IdentityApiException(
      statusCode: exception.statusCode,
      message: exception.message,
    );
  }

  void dispose() {
    _apiClient.dispose();
  }
}

class IdentityApiException implements Exception {
  IdentityApiException({required this.statusCode, required this.message});

  final int? statusCode;
  final String message;

  @override
  String toString() {
    if (statusCode != null) {
      return 'IdentityApiException($statusCode): $message';
    }

    return 'IdentityApiException: $message';
  }
}
