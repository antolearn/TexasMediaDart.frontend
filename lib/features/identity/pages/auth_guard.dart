import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../organization/controllers/module_permissions_controller.dart';
import '../services/auth_service.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({required this.child, super.key});

  final Widget child;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isChecking = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final authService = context.read<AuthService>();

    final hasSession = await authService.hasSession();

    if (!mounted) {
      return;
    }

    if (!hasSession) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    final permissionsController = context.read<ModulePermissionsController>();

    await permissionsController.loadModules();

    if (!mounted) {
      return;
    }

    if (permissionsController.hasError) {
      setState(() {
        _errorMessage = permissionsController.errorMessage;
        _isChecking = false;
      });

      return;
    }

    setState(() {
      _isAuthenticated = true;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load application permissions.\n\n'
              '$_errorMessage',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
