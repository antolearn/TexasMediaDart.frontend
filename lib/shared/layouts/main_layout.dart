import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../features/identity/services/auth_service.dart';

import '../../../../features/organization/controllers/module_permissions_controller.dart';
import '../../../../features/organization/models/user_module_permission.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({required this.child, super.key});

  final Widget child;
  Future<void> _logout(BuildContext context) async {
    final authService = context.read<AuthService>();
    final permissionsController = context.read<ModulePermissionsController>();

    try {
      await authService.logout();
    } finally {
      permissionsController.clear();

      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsController = context.watch<ModulePermissionsController>();

    final modules =
        permissionsController.modules
            .where(
              (module) =>
                  module.showInMenu &&
                  module.canRead &&
                  module.route != null &&
                  module.route!.isNotEmpty,
            )
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Scaffold(
      appBar: AppBar(title: const Text('TexasMediaDart')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.track_changes),
                title: Text(
                  'TexasMediaDart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: _buildMenuItems(context, modules),
                ),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }

  List<Widget> _buildMenuItems(
    BuildContext context,
    List<UserModulePermission> modules,
  ) {
    final widgets = <Widget>[];
    String? currentGroup;

    for (final module in modules) {
      final group = module.menuGroup?.trim();

      if (group != null && group.isNotEmpty && group != currentGroup) {
        currentGroup = group;

        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(group, style: Theme.of(context).textTheme.labelLarge),
          ),
        );
      }

      widgets.add(
        ListTile(
          leading: Icon(_getIcon(module.iconKey)),
          title: Text(module.moduleName),
          onTap: () {
            Navigator.of(context).pop();

            final route = module.route;

            if (route == null || route.isEmpty) {
              return;
            }

            Navigator.of(context).pushNamed(route);
          },
        ),
      );
    }

    return widgets;
  }

  IconData _getIcon(String? iconKey) {
    switch (iconKey) {
      case 'business':
        return Icons.business;

      case 'people':
        return Icons.people;

      case 'groups':
        return Icons.groups;

      case 'security':
        return Icons.security;

      case 'admin_panel_settings':
        return Icons.admin_panel_settings;

      case 'key':
        return Icons.key;

      case 'contacts':
        return Icons.contacts;

      default:
        return Icons.apps;
    }
  }
}
