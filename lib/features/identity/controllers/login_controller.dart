import 'package:flutter/foundation.dart';

import '../models/auth_tokens.dart';
import '../services/auth_service.dart';
import '../services/identity_api_service.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  AuthTokens? _session;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthTokens? get session => _session;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authService.login(
        email: email.trim(),
        password: password,
      );

      return true;
    } on IdentityApiException catch (exception) {
      _errorMessage = exception.message;

      return false;
    } catch (_) {
      _errorMessage = 'Unable to sign in. Please try again.';

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
