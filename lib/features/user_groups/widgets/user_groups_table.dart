import 'package:flutter/material.dart';

import '../models/user_group.dart';
import 'user_group_status_indicator.dart';

class UserGroupsTable extends StatelessWidget {
  const UserGroupsTable({
    super.key,
    required this.userGroups,
    required this.canUpdate,
    required this.canDelete,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    required this.onManageMembers,
    required this.onEdit,
    required this.onDelete,
  });

  final List<UserGroup> userGroups;
  final bool canUpdate;
  final bool canDelete;

  final String? sortBy;
  final bool sortAscending;
  final void Function(String sortBy, bool ascending) onSort;

  final ValueChanged<UserGroup> onManageMembers;
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
            sortColumnIndex: _sortColumnIndex,
            sortAscending: sortAscending,
            columns: [
              DataColumn(
                label: const Text('Name'),
                onSort: (_, ascending) {
                  onSort('name', ascending);
                },
              ),
              DataColumn(
                label: const Text('Description'),
                onSort: (_, ascending) {
                  onSort('description', ascending);
                },
              ),
              const DataColumn(label: Text('Status')),
              const DataColumn(label: Text('Approved')),
              const DataColumn(label: Text('Created By')),
              DataColumn(
                label: const Text('Created Date'),
                onSort: (_, ascending) {
                  onSort('createdUtc', ascending);
                },
              ),
              const DataColumn(label: Text('Actions')),
            ],
            rows: userGroups.map(_buildUserGroupRow).toList(),
          ),
        ),
      ),
    );
  }

  int? get _sortColumnIndex {
    switch (sortBy) {
      case 'name':
        return 0;
      case 'description':
        return 1;
      case 'createdUtc':
        return 5;
      default:
        return null;
    }
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();

    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;

    var hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    hour %= 12;
    if (hour == 0) {
      hour = 12;
    }

    final formattedHour = hour.toString().padLeft(2, '0');

    return '$month/$day/$year $formattedHour:$minute $period';
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

        DataCell(Text(_formatDateTime(group.createdUtc))),

        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canModifyGroup)
                IconButton(
                  tooltip: 'Manage Members',
                  onPressed: () => onManageMembers(group),
                  icon: const Icon(Icons.group_outlined),
                ),

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
                const Tooltip(
                  message: 'You have read-only access.',
                  child: Icon(Icons.visibility_outlined, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
