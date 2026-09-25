import 'package:flutter/material.dart';

import '../models/user_group.dart';
import 'user_group_status_indicator.dart';

class UserGroupsTable extends StatelessWidget {
  const UserGroupsTable({
    super.key,
    required this.userGroups,
    required this.canUpdate,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final List<UserGroup> userGroups;
  final bool canUpdate;
  final bool canDelete;

  final ValueChanged<UserGroup> onEdit;
  final ValueChanged<UserGroup> onDelete;

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
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Approved')),
              DataColumn(label: Text('Created By')),
              DataColumn(label: Text('Actions')),
            ],
            rows: userGroups.map(_buildUserGroupRow).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildUserGroupRow(UserGroup group) {
    final canModifyGroup = !group.isDeleted;

    return DataRow(
      cells: [
        DataCell(Text(group.name)),

        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              group.description?.trim().isNotEmpty == true
                  ? group.description!
                  : '-',
            ),
          ),
        ),

        DataCell(
          group.isDeleted
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('Deleted'),
                  ],
                )
              : UserGroupStatusIndicator(
                  value: group.isActive,
                  trueLabel: 'Active',
                  falseLabel: 'Inactive',
                ),
        ),

        DataCell(
          UserGroupStatusIndicator(
            value: group.isApproved,
            trueLabel: 'Approved',
            falseLabel: 'Not approved',
          ),
        ),

        DataCell(Text(group.createdBy)),

        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canUpdate && canModifyGroup)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => onEdit(group),
                  icon: const Icon(Icons.edit_outlined),
                ),

              if (canDelete && canModifyGroup)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => onDelete(group),
                  icon: const Icon(Icons.delete_outline),
                ),

              if (group.isDeleted)
                const Tooltip(
                  message: 'Deleted user groups are read-only.',
                  child: Icon(Icons.lock_outline, color: Colors.grey),
                ),

              if (!group.isDeleted && !canUpdate && !canDelete)
                const Text('View only', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
