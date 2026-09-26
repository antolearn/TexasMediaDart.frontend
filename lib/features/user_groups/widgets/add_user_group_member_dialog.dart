import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../users/models/organization_user.dart';
import '../../users/services/users_service.dart';
import '../controllers/add_user_group_member_controller.dart';
import '../models/user_group.dart';
import '../models/user_group_member.dart';

class AddUserGroupMemberDialog extends StatelessWidget {
  const AddUserGroupMemberDialog({
    super.key,
    required this.userGroup,
    required this.existingMembers,
  });

  final UserGroup userGroup;
  final List<UserGroupMember> existingMembers;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddUserGroupMemberController>(
      create: (context) => AddUserGroupMemberController(
        context.read<UsersService>(),
        existingMembers: existingMembers,
      )..loadUsers(),
      child: _AddUserGroupMemberDialogContent(userGroup: userGroup),
    );
  }
}

class _AddUserGroupMemberDialogContent extends StatelessWidget {
  const _AddUserGroupMemberDialogContent({required this.userGroup});

  final UserGroup userGroup;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddUserGroupMemberController>();

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add_outlined),
              SizedBox(width: 12),
              Text('Add Member'),
            ],
          ),
          const SizedBox(height: 4),
          Text(userGroup.name, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      content: SizedBox(
        width: 700,
        height: 450,
        child: _buildContent(context, controller),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AddUserGroupMemberController controller,
  ) {
    if (controller.isLoading && controller.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError && controller.users.isEmpty) {
      return _buildError(context, controller);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Select a user to add to this group.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'Refresh users',
              onPressed: controller.isLoading ? null : controller.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: controller.users.isEmpty
              ? _buildEmptyState()
              : _buildUsersTable(context, controller),
        ),
        const SizedBox(height: 16),
        _buildPagination(controller),
      ],
    );
  }

  Widget _buildUsersTable(
    BuildContext context,
    AddUserGroupMemberController controller,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Approved')),
              DataColumn(label: Text('Action')),
            ],
            rows: controller.users
                .map((user) => _buildUserRow(context, user))
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildUserRow(BuildContext context, OrganizationUser user) {
    final email = user.email?.trim();

    return DataRow(
      cells: [
        DataCell(
          Text(email == null || email.isEmpty ? user.identityUserId : email),
        ),
        DataCell(
          _buildStatus(
            user.isActive && user.identityIsActive,
            trueLabel: 'Active',
            falseLabel: 'Inactive',
          ),
        ),
        DataCell(
          _buildStatus(
            user.isApproved,
            trueLabel: 'Approved',
            falseLabel: 'Not approved',
          ),
        ),
        DataCell(
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop(user);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatus(
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

  Widget _buildPagination(AddUserGroupMemberController controller) {
    return Row(
      children: [
        Text(
          controller.totalCount == 0
              ? 'No users'
              : 'Page ${controller.pageNumber} '
                    'of ${controller.totalPages}',
        ),
        const Spacer(),
        const Text('Rows per page:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: controller.pageSize,
          items: AddUserGroupMemberController.allowedPageSizes
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
          Icon(Icons.person_search_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No available users.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'All users on this page may already belong '
            'to the group.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    AddUserGroupMemberController controller,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Unable to load users.',
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
}
