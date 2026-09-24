import 'package:flutter/material.dart';

import '../models/role.dart';

class DeleteRoleDialog extends StatelessWidget {
  const DeleteRoleDialog({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Role'),
      content: Text(
        'Are you sure you want to delete the role '
        '"${role.name}"?\n\n'
        'This role will no longer be available for use.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Role'),
        ),
      ],
    );
  }
}
