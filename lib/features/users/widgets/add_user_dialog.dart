import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/users_controller.dart';
import '../models/organization_user.dart';
import '../../../core/network/api_exception.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<UsersController>();

    if (controller.isAddingUser) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      final user = await controller.addUser(_emailController.text);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop<OrganizationUser>(user);
    } catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _displayError(exception);
      });
    }
  }

  String _displayError(Object exception) {
    if (exception is ApiException) {
      return exception.message;
    }

    if (exception is ArgumentError) {
      return exception.message?.toString() ?? 'Invalid input.';
    }

    return exception.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isAddingUser = context.select<UsersController, bool>(
      (controller) => controller.isAddingUser,
    );

    return AlertDialog(
      title: const Text('Add User'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the email address of an existing TexasDart user.',
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                autofocus: true,
                enabled: !isAddingUser,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'user@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required.';
                  }

                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!isAddingUser) {
                    _submit();
                  }
                },
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
      ),
      actions: [
        TextButton(
          onPressed: isAddingUser
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: isAddingUser ? null : _submit,
          icon: isAddingUser
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add),
          label: Text(isAddingUser ? 'Adding...' : 'Add User'),
        ),
      ],
    );
  }
}
