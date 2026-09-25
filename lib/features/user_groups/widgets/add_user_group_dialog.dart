import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../controllers/user_groups_controller.dart';

class AddUserGroupDialog extends StatefulWidget {
  const AddUserGroupDialog({super.key});

  @override
  State<AddUserGroupDialog> createState() => _AddUserGroupDialogState();
}

class _AddUserGroupDialogState extends State<AddUserGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await context.read<UserGroupsController>().createUserGroup(
        name: _nameController.text,
        description: _descriptionController.text,
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
        _errorMessage = 'Unable to create the user group. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<UserGroupsController>().isCreating;

    return AlertDialog(
      title: const Text('Create User Group'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isCreating ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: isCreating ? null : _save,
          child: isCreating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
