import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../controllers/user_groups_controller.dart';
import '../models/user_group.dart';

class DeleteUserGroupDialog extends StatefulWidget {
  const DeleteUserGroupDialog({required this.userGroup, super.key});

  final UserGroup userGroup;

  @override
  State<DeleteUserGroupDialog> createState() => _DeleteUserGroupDialogState();
}

class _DeleteUserGroupDialogState extends State<DeleteUserGroupDialog> {
  String? _errorMessage;

  Future<void> _delete() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      await context.read<UserGroupsController>().deleteUserGroup(
        userGroupId: widget.userGroup.userGroupId,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = exception.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to delete the user group. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.watch<UserGroupsController>().isDeleting;

    return AlertDialog(
      title: const Text('Delete User Group'),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this user group?'),
            const SizedBox(height: 16),
            Text(
              widget.userGroup.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.userGroup.description != null &&
                widget.userGroup.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(widget.userGroup.description!),
            ],
            const SizedBox(height: 16),
            const Text(
              'This action will remove the user group from the active list.',
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isDeleting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isDeleting ? null : _delete,
          child: isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
