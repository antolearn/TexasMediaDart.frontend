import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_tokens.dart';

class SessionManager {
  static const _sessionKey = 'identity_session';

  Future<void> saveSession(AuthTokens tokens) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(tokens.toJson());

    await preferences.setString(_sessionKey, jsonString);
  }

  Future<AuthTokens?> getSession() async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = preferences.getString(_sessionKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    return AuthTokens.fromJson(json);
  }

  Future<String?> getAccessToken() async {
    final session = await getSession();

    return session?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    final session = await getSession();

    return session?.refreshToken;
  }

  Future<bool> hasSession() async {
    final session = await getSession();

    return session != null;
  }

  Future<bool> isAccessTokenExpired() async {
    final session = await getSession();

    if (session == null) {
      return true;
    }

    return session.isAccessTokenExpired;
  }

  Future<bool> isRefreshTokenExpired() async {
    final session = await getSession();

    if (session == null) {
      return true;
    }

    return session.isRefreshTokenExpired;
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_sessionKey);
  }
}
