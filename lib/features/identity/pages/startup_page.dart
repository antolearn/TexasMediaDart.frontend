import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
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
    final authService = context.read<AuthService>();
    final organizationService = context.read<OrganizationService>();

    try {
      final isLoggedIn = await authService.isLoggedIn();

      if (!mounted) {
        return;
      }

      if (!isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.introduction);

        return;
      }

      final organization = await organizationService.getCurrentOrganization();

      if (!mounted) {
        return;
      }

      if (organization == null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.organizationSetup);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
