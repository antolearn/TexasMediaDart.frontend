import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/roles_controller.dart';
import '../models/role.dart';
import '../models/role_permission.dart';

class RolePermissionsDialog extends StatefulWidget {
  const RolePermissionsDialog({super.key, required this.role});

  final Role role;

  @override
  State<RolePermissionsDialog> createState() => _RolePermissionsDialogState();
}

class _RolePermissionsDialogState extends State<RolePermissionsDialog> {
  final Map<int, _EditablePermission> _editedPermissions = {};

  bool _initialized = false;

  bool get _canEdit => !widget.role.isSystemRole && !widget.role.isDeleted;

  @override
  @override
  void initState() {
    super.initState();

    final controller = context.read<RolesController>();

    // Remove permissions belonging to the previously opened role
    // before this dialog renders its permission matrix.
    controller.clearRolePermissions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      controller.loadRolePermissions(widget.role.roleId);
    });
  }

  void _initializeEditablePermissions(List<RolePermission> permissions) {
    if (_initialized) {
      return;
    }

    _editedPermissions.clear();

    for (final permission in permissions) {
      _editedPermissions[permission.moduleId] = _EditablePermission(
        canRead: permission.canRead,
        canCreate: permission.canCreate,
        canUpdate: permission.canUpdate,
        canDelete: permission.canDelete,
        canApprove: permission.canApprove,
      );
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Role Permissions - ${widget.role.name}'),
      content: SizedBox(
        width: 850,
        height: 500,
        child: Consumer<RolesController>(
          builder: (context, controller, child) {
            if (controller.isLoadingPermissions) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = controller.permissionsError;

            if (error != null && controller.rolePermissions.isEmpty) {
              return _buildLoadError(controller, error);
            }

            final permissions = controller.rolePermissions;

            if (permissions.isEmpty) {
              return const Center(
                child: Text('No permissions are available for this role.'),
              );
            }

            _initializeEditablePermissions(permissions);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_canEdit) ...[
                  _buildReadOnlyMessage(),
                  const SizedBox(height: 12),
                ],
                if (error != null) ...[
                  _buildSaveError(error),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: _PermissionsTable(
                    permissions: permissions,
                    editedPermissions: _editedPermissions,
                    editable: _canEdit && !controller.isSavingPermissions,
                    onChanged: _handlePermissionChanged,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        Consumer<RolesController>(
          builder: (context, controller, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: controller.isSavingPermissions
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(_canEdit ? 'Cancel' : 'Close'),
                ),
                if (_canEdit) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed:
                        controller.isSavingPermissions ||
                            controller.isLoadingPermissions ||
                            !_initialized
                        ? null
                        : () => _savePermissions(controller),
                    icon: controller.isSavingPermissions
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      controller.isSavingPermissions ? 'Saving...' : 'Save',
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadError(RolesController controller, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              _initialized = false;
              _editedPermissions.clear();

              controller.loadRolePermissions(widget.role.roleId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyMessage() {
    final message = widget.role.isSystemRole
        ? 'System role permissions are read-only.'
        : 'Deleted role permissions are read-only.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _buildSaveError(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(error)),
        ],
      ),
    );
  }

  void _handlePermissionChanged(
    int moduleId,
    _PermissionType type,
    bool value,
  ) {
    if (!_canEdit) {
      return;
    }

    final editedPermission = _editedPermissions[moduleId];

    if (editedPermission == null) {
      return;
    }

    setState(() {
      switch (type) {
        case _PermissionType.read:
          editedPermission.canRead = value;
          break;

        case _PermissionType.create:
          editedPermission.canCreate = value;
          break;

        case _PermissionType.update:
          editedPermission.canUpdate = value;
          break;

        case _PermissionType.delete:
          editedPermission.canDelete = value;
          break;

        case _PermissionType.approve:
          editedPermission.canApprove = value;
          break;
      }
    });
  }

  Future<void> _savePermissions(RolesController controller) async {
    final permissions = controller.rolePermissions;

    final updatedPermissions = permissions.map((permission) {
      final edited = _editedPermissions[permission.moduleId];

      if (edited == null) {
        return permission;
      }

      return RolePermission(
        roleId: permission.roleId,
        moduleId: permission.moduleId,
        moduleCode: permission.moduleCode,
        moduleName: permission.moduleName,
        supportsCreate: permission.supportsCreate,
        supportsRead: permission.supportsRead,
        supportsUpdate: permission.supportsUpdate,
        supportsDelete: permission.supportsDelete,
        supportsApprove: permission.supportsApprove,
        allowedCanCreate: permission.allowedCanCreate,
        allowedCanUpdate: permission.allowedCanUpdate,
        allowedCanDelete: permission.allowedCanDelete,
        allowedCanRead: permission.allowedCanRead,
        allowedCanApprove: permission.allowedCanApprove,
        canCreate: edited.canCreate,
        canUpdate: edited.canUpdate,
        canDelete: edited.canDelete,
        canRead: edited.canRead,
        canApprove: edited.canApprove,
        createdBy: permission.createdBy,
        createdUtc: permission.createdUtc,
        modifiedBy: permission.modifiedBy,
        modifiedUtc: permission.modifiedUtc,
      );
    }).toList();

    final saved = await controller.saveRolePermissions(
      roleId: widget.role.roleId,
      permissions: updatedPermissions,
    );

    if (!mounted || !saved) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}

class _PermissionsTable extends StatelessWidget {
  const _PermissionsTable({
    required this.permissions,
    required this.editedPermissions,
    required this.editable,
    required this.onChanged,
  });

  final List<RolePermission> permissions;

  final Map<int, _EditablePermission> editedPermissions;

  final bool editable;

  final void Function(int moduleId, _PermissionType type, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Module')),
            DataColumn(label: Text('Read')),
            DataColumn(label: Text('Create')),
            DataColumn(label: Text('Update')),
            DataColumn(label: Text('Delete')),
            DataColumn(label: Text('Approve')),
          ],
          rows: permissions.map(_buildRow).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(RolePermission permission) {
    final edited = editedPermissions[permission.moduleId];

    return DataRow(
      cells: [
        DataCell(
          Tooltip(
            message: permission.moduleCode,
            child: Text(permission.moduleName),
          ),
        ),
        DataCell(
          _PermissionCell(
            supported: permission.supportsRead,
            allowed: permission.allowedCanRead,
            granted: edited?.canRead ?? permission.canRead,
            editable: editable,
            onChanged: (value) {
              onChanged(permission.moduleId, _PermissionType.read, value);
            },
          ),
        ),
        DataCell(
          _PermissionCell(
            supported: permission.supportsCreate,
            allowed: permission.allowedCanCreate,
            granted: edited?.canCreate ?? permission.canCreate,
            editable: editable,
            onChanged: (value) {
              onChanged(permission.moduleId, _PermissionType.create, value);
            },
          ),
        ),
        DataCell(
          _PermissionCell(
            supported: permission.supportsUpdate,
            allowed: permission.allowedCanUpdate,
            granted: edited?.canUpdate ?? permission.canUpdate,
            editable: editable,
            onChanged: (value) {
              onChanged(permission.moduleId, _PermissionType.update, value);
            },
          ),
        ),
        DataCell(
          _PermissionCell(
            supported: permission.supportsDelete,
            allowed: permission.allowedCanDelete,
            granted: edited?.canDelete ?? permission.canDelete,
            editable: editable,
            onChanged: (value) {
              onChanged(permission.moduleId, _PermissionType.delete, value);
            },
          ),
        ),
        DataCell(
          _PermissionCell(
            supported: permission.supportsApprove,
            allowed: permission.allowedCanApprove,
            granted: edited?.canApprove ?? permission.canApprove,
            editable: editable,
            onChanged: (value) {
              onChanged(permission.moduleId, _PermissionType.approve, value);
            },
          ),
        ),
      ],
    );
  }
}

class _PermissionCell extends StatelessWidget {
  const _PermissionCell({
    required this.supported,
    required this.allowed,
    required this.granted,
    required this.editable,
    required this.onChanged,
  });

  final bool supported;
  final bool allowed;
  final bool granted;
  final bool editable;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!supported) {
      return const Tooltip(
        message: 'This operation is not supported by the module.',
        child: Icon(Icons.remove, color: Colors.grey),
      );
    }

    if (!allowed) {
      return const Tooltip(
        message: 'This permission is not available under the organization entitlement.',
        child: Icon(Icons.block_outlined, color: Colors.grey),
      );
    }

    if (!editable) {
      if (granted) {
        return const Tooltip(
          message: 'Permission granted',
          child: Icon(Icons.check_circle_outline),
        );
      }

      return const Tooltip(
        message: 'Permission not granted',
        child: Icon(Icons.radio_button_unchecked, color: Colors.grey),
      );
    }

    return Checkbox(
      value: granted,
      onChanged: (value) {
        if (value == null) {
          return;
        }

        onChanged(value);
      },
    );
  }
}

class _EditablePermission {
  _EditablePermission({
    required this.canRead,
    required this.canCreate,
    required this.canUpdate,
    required this.canDelete,
    required this.canApprove,
  });

  bool canRead;
  bool canCreate;
  bool canUpdate;
  bool canDelete;
  bool canApprove;
}

enum _PermissionType { read, create, update, delete, approve }
