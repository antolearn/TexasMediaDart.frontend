import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../organization/controllers/module_permissions_controller.dart';
import '../../organization/services/organization_service.dart';
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
    final organizationService = context.read<OrganizationService>();
    final permissionsController = context.read<ModulePermissionsController>();

    try {
      //
      // 1. Verify that a valid session exists.
      //
      final hasSession = await authService.hasSession();

      if (!mounted) {
        return;
      }

      if (!hasSession) {
        permissionsController.clear();

        Navigator.of(context).pushReplacementNamed(AppRoutes.login);

        return;
      }

      //
      // 2. Determine the current organization state.
      //
      final organization = await organizationService.getCurrentOrganization();

      if (!mounted) {
        return;
      }

      //
      // Authenticated user does not belong to an organization.
      //
      if (organization == null) {
        permissionsController.clear();

        Navigator.of(context).pushReplacementNamed(AppRoutes.organizationSetup);

        return;
      }

      //
      // Organization exists but has been deactivated.
      //
      if (!organization.isActive) {
        permissionsController.clear();

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.organizationDeactivated,
          (route) => false,
          arguments: organization,
        );

        return;
      }

      //
      // Future organization-user lifecycle checks:
      //
      // if (!organization.userIsActive) {
      //   ...
      // }
      //
      // if (!organization.userIsApproved) {
      //   ...
      // }
      //

      //
      // 3. Organization is valid. Load effective permissions.
      //
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

      //
      // 4. Allow the protected page to render.
      //
      setState(() {
        _isAuthenticated = true;
        _isChecking = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      permissionsController.clear();

      setState(() {
        _errorMessage =
            'Unable to verify application access. Please try again.';
        _isChecking = false;
      });
    }
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
            child: Text(_errorMessage!, textAlign: TextAlign.center),
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
