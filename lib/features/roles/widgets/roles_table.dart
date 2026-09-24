import 'package:flutter/material.dart';

import '../models/role.dart';
import 'role_status_indicator.dart';

class RolesTable extends StatelessWidget {
  const RolesTable({
    super.key,
    required this.roles,
    required this.canUpdate,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
    required this.onAudit,
  });

  final List<Role> roles;
  final bool canUpdate;
  final bool canDelete;

  final ValueChanged<Role> onEdit;
  final ValueChanged<Role> onDelete;
  final ValueChanged<Role> onAudit;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            rows: roles.map(_buildRoleRow).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRoleRow(Role role) {
    final canModifyRole = !role.isSystemRole && !role.isDeleted;

    return DataRow(
      cells: [
        // Name
        DataCell(Text(role.name)),

        // Description
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

        // Type
        DataCell(
          role.isSystemRole
              ? const Chip(label: Text('System'))
              : const Text('Custom'),
        ),

        // Status
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
              : RoleStatusIndicator(
                  value: role.isActive,
                  trueLabel: 'Active',
                  falseLabel: 'Inactive',
                ),
        ),

        // Approved
        DataCell(
          RoleStatusIndicator(
            value: role.isApproved,
            trueLabel: 'Approved',
            falseLabel: 'Not approved',
          ),
        ),

        // Created
        DataCell(Text(_formatDateTime(role.createdUtc))),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Audit is read-only and available for every role.
              IconButton(
                tooltip: 'View audit information',
                onPressed: () => onAudit(role),
                icon: const Icon(Icons.history),
              ),

              // Custom, non-deleted roles can be edited
              // when the user has update permission.
              if (canUpdate && canModifyRole)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => onEdit(role),
                  icon: const Icon(Icons.edit_outlined),
                ),

              // Custom, non-deleted roles can be deleted
              // when the user has delete permission.
              if (canDelete && canModifyRole)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => onDelete(role),
                  icon: const Icon(Icons.delete_outline),
                ),

              // System roles are read-only.
              if (role.isSystemRole)
                const Tooltip(
                  message: 'System roles cannot be modified.',
                  child: Icon(Icons.lock_outline, color: Colors.grey),
                ),

              // Deleted roles are read-only.
              if (role.isDeleted)
                const Tooltip(
                  message: 'Deleted roles are read-only.',
                  child: Icon(Icons.lock_outline, color: Colors.grey),
                ),

              // Custom role where the current user does not
              // have update/delete permission.
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
