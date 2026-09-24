import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../organization/controllers/module_permissions_controller.dart';
import '../controllers/roles_controller.dart';
import '../models/role.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  final TextEditingController _searchController = TextEditingController();

  bool? _selectedIsActive = true;
  bool _includeDeleted = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RolesController>();
    final permissions = context.watch<ModulePermissionsController>();

    final canCreate = permissions.canCreate('ROLES');
    final canUpdate = permissions.canUpdate('ROLES');
    final canDelete = permissions.canDelete('ROLES');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, controller, canCreate: canCreate),
          const SizedBox(height: 20),
          _buildFilters(controller),
          const SizedBox(height: 20),
          Expanded(
            child: _buildContent(
              controller,
              canUpdate: canUpdate,
              canDelete: canDelete,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    RolesController controller, {
    required bool canCreate,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Roles',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Manage organization roles and permissions.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh search results',
          onPressed: controller.hasSearched && !controller.isLoading
              ? controller.refresh
              : null,
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
        if (canCreate)
          FilledButton.icon(
            onPressed: controller.isCreating
                ? null
                : () => _showAddRoleDialog(controller),
            icon: const Icon(Icons.add),
            label: const Text('Add Role'),
          ),
      ],
    );
  }

  Widget _buildFilters(RolesController controller) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: TextField(
            controller: _searchController,
            enabled: !controller.isLoading,
            decoration: const InputDecoration(
              labelText: 'Search roles',
              hintText: 'Role name or description',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _applyFilters(controller),
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<bool?>(
            initialValue: _selectedIsActive,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool?>(value: null, child: Text('All')),
              DropdownMenuItem<bool?>(value: true, child: Text('Active')),
              DropdownMenuItem<bool?>(value: false, child: Text('Inactive')),
            ],
            onChanged: controller.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedIsActive = value;
                    });
                  },
          ),
        ),
        SizedBox(
          width: 180,
          child: CheckboxListTile(
            value: _includeDeleted,
            onChanged: controller.isLoading
                ? null
                : (value) {
                    setState(() {
                      _includeDeleted = value ?? false;
                    });
                  },
            title: const Text('Include deleted'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        FilledButton.icon(
          onPressed: controller.isLoading
              ? null
              : () => _applyFilters(controller),
          icon: const Icon(Icons.search),
          label: const Text('Apply'),
        ),
        TextButton.icon(
          onPressed: controller.isLoading
              ? null
              : () => _clearFilters(controller),
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
        ),
      ],
    );
  }

  Future<void> _applyFilters(RolesController controller) async {
    await controller.applyFilters(
      search: _searchController.text.trim(),
      isActive: _selectedIsActive,
      includeDeleted: _includeDeleted,
    );
  }

  void _clearFilters(RolesController controller) {
    _searchController.clear();

    setState(() {
      _selectedIsActive = true;
      _includeDeleted = false;
    });

    controller.clearFilters();
  }

  Future<void> _showAddRoleDialog(RolesController controller) async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _AddRoleDialog(controller: controller);
      },
    );

    if (!mounted || created != true) {
      return;
    }

    await controller.refreshAfterCreate();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Role created successfully.')));
  }

  Future<void> _showEditRoleDialog(
    Role role,
    RolesController controller,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditRoleDialog(controller: controller, role: role);
      },
    );

    if (!mounted || updated != true) {
      return;
    }

    await controller.refreshAfterCreate();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Role updated successfully.')));
  }

  Future<void> _showDeleteRoleDialog(
    Role role,
    RolesController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Role'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await controller.deleteRole(roleId: role.roleId);

      if (!mounted) {
        return;
      }

      await controller.refresh();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role "${role.name}" deleted successfully.')),
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete role: $exception')),
      );
    }
  }

  Widget _buildContent(
    RolesController controller, {
    required bool canUpdate,
    required bool canDelete,
  }) {
    if (!controller.hasSearched) {
      return _buildInitialSearchState();
    }

    if (controller.isLoading && controller.roles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return _buildError(controller);
    }

    if (controller.roles.isEmpty) {
      return _buildNoResults();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Approved')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: controller.roles
                      .map(
                        (role) => _buildRoleRow(
                          role,
                          canUpdate: canUpdate,
                          canDelete: canDelete,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPagination(controller),
      ],
    );
  }

  Widget _buildInitialSearchState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_search, size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          const Text(
            'Search for roles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your search criteria and click Apply.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          const Text(
            'No roles found.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your search criteria.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  DataRow _buildRoleRow(
    Role role, {
    required bool canUpdate,
    required bool canDelete,
  }) {
    final canModifyRole = !role.isSystemRole && !role.isDeleted;

    return DataRow(
      cells: [
        DataCell(Text(role.name)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              role.description?.trim().isNotEmpty == true
                  ? role.description!
                  : '-',
            ),
          ),
        ),
        DataCell(
          role.isSystemRole
              ? const Chip(label: Text('System'))
              : const Text('Custom'),
        ),
        DataCell(
          role.isDeleted
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('Deleted'),
                  ],
                )
              : _StatusIndicator(
                  value: role.isActive,
                  trueLabel: 'Active',
                  falseLabel: 'Inactive',
                ),
        ),
        DataCell(
          _StatusIndicator(
            value: role.isApproved,
            trueLabel: 'Approved',
            falseLabel: 'Not approved',
          ),
        ),
        DataCell(Text(_formatDateTime(role.createdUtc))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canUpdate && canModifyRole)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _showEditRoleDialog(
                    role,
                    context.read<RolesController>(),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (canDelete && canModifyRole)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _showDeleteRoleDialog(
                    role,
                    context.read<RolesController>(),
                  ),
                  icon: const Icon(Icons.delete_outline),
                ),
              if (role.isSystemRole)
                const Tooltip(
                  message: 'System roles cannot be modified.',
                  child: Icon(Icons.lock_outline, color: Colors.grey),
                ),
              if (role.isDeleted)
                const Tooltip(
                  message: 'Deleted roles are read-only.',
                  child: Icon(Icons.lock_outline, color: Colors.grey),
                ),
              if (!role.isSystemRole &&
                  !role.isDeleted &&
                  !canUpdate &&
                  !canDelete)
                const Text('View only', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(RolesController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Unable to load roles.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: controller.isLoading ? null : controller.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(RolesController controller) {
    final firstItem = controller.totalCount == 0
        ? 0
        : ((controller.pageNumber - 1) * controller.pageSize) + 1;

    final calculatedLastItem = controller.pageNumber * controller.pageSize;

    final lastItem = calculatedLastItem > controller.totalCount
        ? controller.totalCount
        : calculatedLastItem;

    final hasMultiplePages = controller.totalCount > controller.pageSize;

    final recordText = hasMultiplePages
        ? 'Showing $firstItem-$lastItem of ${controller.totalCount}'
        : '${controller.totalCount} '
              '${controller.totalCount == 1 ? 'record' : 'records'}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(recordText, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (hasMultiplePages) ...[
            const Spacer(),
            IconButton(
              tooltip: 'Previous page',
              onPressed: controller.hasPreviousPage && !controller.isLoading
                  ? controller.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Page ${controller.pageNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: controller.hasNextPage && !controller.isLoading
                  ? controller.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${local.year}-'
        '${twoDigits(local.month)}-'
        '${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }
}

class _AddRoleDialog extends StatefulWidget {
  const _AddRoleDialog({required this.controller});

  final RolesController controller;

  @override
  State<_AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<_AddRoleDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.controller.createRole(
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
        _errorMessage = 'Unable to create role. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Role'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                enabled: !_isSaving,
                maxLength: 100,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Role name',
                  hintText: 'Enter role name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Role name is required.';
                  }

                  if (name.length > 100) {
                    return 'Role name cannot exceed 100 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSaving,
                maxLength: 500,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter role description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final description = value?.trim() ?? '';

                  if (description.length > 500) {
                    return 'Description cannot exceed 500 characters.';
                  }

                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'Creating...' : 'Create Role'),
        ),
      ],
    );
  }
}

class _EditRoleDialog extends StatefulWidget {
  const _EditRoleDialog({required this.controller, required this.role});

  final RolesController controller;
  final Role role;

  @override
  State<_EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<_EditRoleDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late bool _isActive;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.role.name);

    _descriptionController = TextEditingController(
      text: widget.role.description ?? '',
    );

    _isActive = widget.role.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.controller.updateRole(
        roleId: widget.role.roleId,
        name: _nameController.text,
        description: _descriptionController.text,
        isActive: _isActive,
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
        _errorMessage = 'Unable to update role. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Role'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                enabled: !_isSaving,
                maxLength: 100,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Role name',
                  hintText: 'Enter role name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Role name is required.';
                  }

                  if (name.length > 100) {
                    return 'Role name cannot exceed 100 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSaving,
                maxLength: 500,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter role description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final description = value?.trim() ?? '';

                  if (description.length > 500) {
                    return 'Description cannot exceed 500 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: Text(
                  _isActive ? 'This role is active.' : 'This role is inactive.',
                ),
                value: _isActive,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
  });

  final bool value;
  final String trueLabel;
  final String falseLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 18,
          color: value ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(value ? trueLabel : falseLabel),
      ],
    );
  }
}
