import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../organization/controllers/module_permissions_controller.dart';
import '../../organization/services/organization_service.dart';
import '../services/auth_service.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStartupState();
    });
  }

  Future<void> _checkStartupState() async {
    //
    // Handle public deep links before authentication routing.
    //
    final deepLinkHandled = _handlePublicDeepLink();

    if (deepLinkHandled) {
      return;
    }

    //
    // Normal application startup.
    //
    final authService = context.read<AuthService>();
    final organizationService = context.read<OrganizationService>();
    final permissionsController = context.read<ModulePermissionsController>();

    try {
      final isLoggedIn = await authService.isLoggedIn();

      if (!mounted) {
        return;
      }

      //
      // User is not authenticated.
      //
      if (!isLoggedIn) {
        permissionsController.clear();

        Navigator.of(context).pushReplacementNamed(AppRoutes.introduction);

        return;
      }

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

        Navigator.of(context).pushReplacementNamed(
          AppRoutes.organizationDeactivated,
          arguments: organization,
        );

        return;
      }

      //
      // Future:
      //
      // if (!organization.userIsActive) {
      //   ...
      // }
      //
      // if (!organization.userIsApproved) {
      //   ...
      // }
      //

      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (exception) {
      if (!mounted) {
        return;
      }

      permissionsController.clear();

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  bool _handlePublicDeepLink() {
    final uri = Uri.base;
    final fragment = uri.fragment;

    if (fragment.isEmpty) {
      return false;
    }

    final deepLinkUri = Uri.tryParse(
      fragment.startsWith('/') ? fragment : '/$fragment',
    );

    if (deepLinkUri == null) {
      return false;
    }

    final token = deepLinkUri.queryParameters['token'];

    if (token == null || token.trim().isEmpty) {
      return false;
    }

    //
    // User invitation deep link.
    //
    if (deepLinkUri.path == AppRoutes.acceptInvitation) {
      Navigator.of(context).pushReplacementNamed(
        '${AppRoutes.acceptInvitation}'
        '?token=${Uri.encodeQueryComponent(token)}',
      );

      return true;
    }

    //
    // Email verification deep link.
    //
    if (deepLinkUri.path == AppRoutes.verifyEmail) {
      Navigator.of(context).pushReplacementNamed(
        '${AppRoutes.verifyEmail}'
        '?token=${Uri.encodeQueryComponent(token)}',
      );

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
