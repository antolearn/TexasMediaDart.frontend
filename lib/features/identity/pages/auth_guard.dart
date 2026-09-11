import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../services/auth_service.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({required this.child, super.key});

  final Widget child;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final AuthService _authService = AuthService();

  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final hasSession = await _authService.hasSession();

    if (!mounted) {
      return;
    }

    if (!hasSession) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    setState(() {
      _isAuthenticated = true;
      _isChecking = false;
    });
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAuthenticated) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
