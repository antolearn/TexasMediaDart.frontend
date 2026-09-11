import '../models/auth_tokens.dart';
import '../models/user_profile.dart';
import 'identity_api_service.dart';
import 'session_manager.dart';

class AuthService {
  AuthService({
    IdentityApiService? identityApiService,
    SessionManager? sessionManager,
  }) : _identityApiService = identityApiService ?? IdentityApiService(),
       _sessionManager = sessionManager ?? SessionManager();

  final IdentityApiService _identityApiService;
  final SessionManager _sessionManager;

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _identityApiService.login(
      email: email,
      password: password,
    );

    await _sessionManager.saveSession(tokens);

    return tokens;
  }

  Future<UserProfile> getCurrentUser() async {
    final session = await _sessionManager.getSession();

    if (session == null) {
      throw StateError('No active session.');
    }

    return _identityApiService.getMe(accessToken: session.accessToken);
  }

  Future<bool> isLoggedIn() async {
    final session = await _sessionManager.getSession();

    if (session == null) {
      return false;
    }

    if (session.refreshTokenExpiresAtUtc.isBefore(DateTime.now().toUtc())) {
      await _sessionManager.clearSession();
      return false;
    }

    try {
      await _identityApiService.getMe(accessToken: session.accessToken);

      return true;
    } on IdentityApiException catch (ex) {
      if (ex.statusCode == 401) {
        await _sessionManager.clearSession();
        return false;
      }

      rethrow;
    }
  }

  Future<void> logout() async {
    final session = await _sessionManager.getSession();

    if (session != null) {
      try {
        await _identityApiService.logout(refreshToken: session.refreshToken);
      } finally {
        await _sessionManager.clearSession();
      }
    }
  }

  Future<bool> hasSession() async {
    final session = await _sessionManager.getSession();

    if (session == null) {
      return false;
    }

    if (session.refreshTokenExpiresAtUtc.isBefore(DateTime.now().toUtc())) {
      await _sessionManager.clearSession();
      return false;
    }

    return true;
  }

  void dispose() {
    _identityApiService.dispose();
  }
}
