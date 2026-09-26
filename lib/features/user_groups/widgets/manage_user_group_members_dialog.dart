import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../users/models/organization_user.dart';
import '../controllers/user_group_members_controller.dart';
import '../models/user_group.dart';
import '../models/user_group_member.dart';
import '../services/user_groups_service.dart';
import 'add_user_group_member_dialog.dart';

class ManageUserGroupMembersDialog extends StatelessWidget {
  const ManageUserGroupMembersDialog({
    super.key,
    required this.userGroup,
    required this.canUpdate,
  });

  final UserGroup userGroup;
  final bool canUpdate;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserGroupMembersController>(
      create: (context) =>
          UserGroupMembersController(context.read<UserGroupsService>())
            ..loadMembers(userGroupId: userGroup.userGroupId),
      child: _ManageUserGroupMembersDialogContent(
        userGroup: userGroup,
        canUpdate: canUpdate,
      ),
    );
  }
}

class _ManageUserGroupMembersDialogContent extends StatelessWidget {
  const _ManageUserGroupMembersDialogContent({
    required this.userGroup,
    required this.canUpdate,
  });

  final UserGroup userGroup;
  final bool canUpdate;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserGroupMembersController>();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.group_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage Members'),
                const SizedBox(height: 2),
                Text(
                  userGroup.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 500,
        child: _buildContent(context, controller),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserGroupMembersController controller,
  ) {
    if (controller.isLoading && controller.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError && controller.members.isEmpty) {
      return _buildError(context, controller);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(context, controller),
        const SizedBox(height: 16),
        Expanded(
          child: controller.members.isEmpty
              ? _buildEmptyState()
              : _buildMembersTable(context, controller),
        ),
        const SizedBox(height: 16),
        _buildPagination(controller),
      ],
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    UserGroupMembersController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${controller.totalCount} member'
            '${controller.totalCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Refresh members',
          onPressed: controller.isLoading ? null : controller.refresh,
          icon: const Icon(Icons.refresh),
        ),
        if (canUpdate) ...[
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: controller.isAdding
                ? null
                : () {
                    _showAddMemberDialog(context, controller);
                  },
            icon: controller.isAdding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add_outlined),
            label: const Text('Add Member'),
          ),
        ],
      ],
    );
  }

  Widget _buildMembersTable(
    BuildContext context,
    UserGroupMembersController controller,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Organization User ID')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Approved')),
              DataColumn(label: Text('Actions')),
              DataColumn(label: Text('Identity User ID')),
              DataColumn(label: Text('Created By')),
              DataColumn(label: Text('Created Date')),
            ],
            rows: controller.members
                .map((member) => _buildMemberRow(context, controller, member))
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildMemberRow(
    BuildContext context,
    UserGroupMembersController controller,
    UserGroupMember member,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(member.organizationUserId.toString())),
        DataCell(
          _buildBooleanStatus(
            member.isActive,
            trueLabel: 'Active',
            falseLabel: 'Inactive',
          ),
        ),
        DataCell(
          _buildBooleanStatus(
            member.isApproved,
            trueLabel: 'Approved',
            falseLabel: 'Not approved',
          ),
        ),
        DataCell(
          canUpdate
              ? IconButton(
                  tooltip: 'Remove member',
                  onPressed: controller.isRemoving
                      ? null
                      : () {
                          _confirmRemoveMember(context, controller, member);
                        },
                  icon: const Icon(Icons.person_remove_outlined),
                )
              : const Tooltip(
                  message: 'Read-only access',
                  child: Icon(Icons.visibility_outlined, color: Colors.grey),
                ),
        ),
        DataCell(Text(member.identityUserId)),
        DataCell(
          Text(
            member.membershipCreatedBy.isEmpty
                ? '-'
                : member.membershipCreatedBy,
          ),
        ),
        DataCell(Text(_formatDateTime(member.membershipCreatedUtc))),
      ],
    );
  }

  Widget _buildBooleanStatus(
    bool value, {
    required String trueLabel,
    required String falseLabel,
  }) {
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

  Widget _buildPagination(UserGroupMembersController controller) {
    return Row(
      children: [
        Text(
          controller.totalCount == 0
              ? 'No members'
              : 'Page ${controller.pageNumber} '
                    'of ${controller.totalPages}',
        ),
        const Spacer(),
        const Text('Rows per page:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: controller.pageSize,
          items: UserGroupMembersController.allowedPageSizes
              .map(
                (pageSize) => DropdownMenuItem<int>(
                  value: pageSize,
                  child: Text(pageSize.toString()),
                ),
              )
              .toList(),
          onChanged: controller.isLoading
              ? null
              : (value) {
                  if (value != null) {
                    controller.changePageSize(value);
                  }
                },
        ),
        const SizedBox(width: 16),
        IconButton(
          tooltip: 'First page',
          onPressed: controller.hasPreviousPage && !controller.isLoading
              ? controller.firstPage
              : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          tooltip: 'Previous page',
          onPressed: controller.hasPreviousPage && !controller.isLoading
              ? controller.previousPage
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next page',
          onPressed: controller.hasNextPage && !controller.isLoading
              ? controller.nextPage
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          tooltip: 'Last page',
          onPressed: controller.hasNextPage && !controller.isLoading
              ? controller.lastPage
              : null,
          icon: const Icon(Icons.last_page),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_off_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No members found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    UserGroupMembersController controller,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Unable to load group members.',
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

  Future<void> _showAddMemberDialog(
    BuildContext context,
    UserGroupMembersController controller,
  ) async {
    final selectedUser = await showDialog<OrganizationUser>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AddUserGroupMemberDialog(
          userGroup: userGroup,
          existingMembers: controller.members,
        );
      },
    );

    if (selectedUser == null || !context.mounted) {
      return;
    }

    try {
      await controller.addMember(
        organizationUserId: selectedUser.organizationUserId,
      );

      if (!context.mounted) {
        return;
      }

      final email = selectedUser.email?.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            email == null || email.isEmpty
                ? 'Member added successfully.'
                : '$email added successfully.',
          ),
        ),
      );
    } catch (exception) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to add member: $exception')),
      );
    }
  }

  Future<void> _confirmRemoveMember(
    BuildContext context,
    UserGroupMembersController controller,
    UserGroupMember member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text(
            'Remove organization user '
            '${member.organizationUserId} '
            'from "${userGroup.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await controller.removeMember(
        organizationUserId: member.organizationUserId,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully.')),
      );
    } catch (exception) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to remove member: $exception')),
      );
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

    return '$month/$day/$year '
        '$formattedHour:$minute $period';
  }
}
