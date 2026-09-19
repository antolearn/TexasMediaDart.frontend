import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/module_permissions_controller.dart';

class ModuleGuard extends StatelessWidget {
  const ModuleGuard({required this.moduleCode, required this.child, super.key});

  final String moduleCode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final permissionsController = context.watch<ModulePermissionsController>();

    if (permissionsController.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (permissionsController.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to verify module permissions.\n\n'
              '${permissionsController.errorMessage}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!permissionsController.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!permissionsController.canRead(moduleCode)) {
      return Scaffold(
        appBar: AppBar(title: const Text('TexasMediaDart')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'You do not have permission to access '
                  'the $moduleCode module.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
