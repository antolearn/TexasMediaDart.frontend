import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../organization/controllers/module_permissions_controller.dart';
import '../controllers/users_controller.dart';
import '../models/organization_user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<UsersController>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UsersController>();
    final permissions = context.watch<ModulePermissionsController>();

    final canCreate = permissions.canCreate('USERS');
    final canUpdate = permissions.canUpdate('USERS');
    final canDelete = permissions.canDelete('USERS');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, controller, canCreate: canCreate),
          const SizedBox(height: 24),
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
    UsersController controller, {
    required bool canCreate,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Manage organization users.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: controller.isLoading ? null : () => controller.refresh(),
          icon: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 8),
        if (canCreate)
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add User will be implemented next.'),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add User'),
          ),
      ],
    );
  }

  Widget _buildContent(
    UsersController controller, {
    required bool canUpdate,
    required bool canDelete,
  }) {
    if (controller.isLoading && controller.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return _buildError(controller);
    }

    if (controller.users.isEmpty) {
      return const Center(child: Text('No users found.'));
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
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Active')),
                    DataColumn(label: Text('Approved')),
                    DataColumn(label: Text('Account Active')),
                    DataColumn(label: Text('Email Verified')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: controller.users
                      .map(
                        (user) => _buildUserRow(
                          user,
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

  DataRow _buildUserRow(
    OrganizationUser user, {
    required bool canUpdate,
    required bool canDelete,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(user.organizationUserId.toString())),
        DataCell(Text(user.email ?? 'Unknown')),
        DataCell(
          _StatusIndicator(
            value: user.isActive,
            trueLabel: 'Active',
            falseLabel: 'Inactive',
          ),
        ),
        DataCell(
          _StatusIndicator(
            value: user.isApproved,
            trueLabel: 'Approved',
            falseLabel: 'Pending',
          ),
        ),
        DataCell(
          _StatusIndicator(
            value: user.identityIsActive,
            trueLabel: 'Active',
            falseLabel: 'Inactive',
          ),
        ),
        DataCell(
          _StatusIndicator(
            value: user.isEmailVerified,
            trueLabel: 'Verified',
            falseLabel: 'Not verified',
          ),
        ),
        DataCell(Text(_formatDateTime(user.createdUtc))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canUpdate)
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () {
                    // Edit User will be implemented next.
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (canDelete)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () {
                    // Delete User will be implemented next.
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              if (!canUpdate && !canDelete)
                const Text('View only', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(UsersController controller) {
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
            onPressed: controller.loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(UsersController controller) {
    final firstItem = controller.totalCount == 0
        ? 0
        : ((controller.pageNumber - 1) * controller.pageSize) + 1;

    final calculatedLastItem = controller.pageNumber * controller.pageSize;

    final lastItem = calculatedLastItem > controller.totalCount
        ? controller.totalCount
        : calculatedLastItem;

    return Row(
      children: [
        Text('$firstItem-$lastItem of ${controller.totalCount}'),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: controller.hasPreviousPage && !controller.isLoading
              ? controller.previousPage
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Page ${controller.pageNumber}'),
        IconButton(
          tooltip: 'Next page',
          onPressed: controller.hasNextPage && !controller.isLoading
              ? controller.nextPage
              : null,
          icon: const Icon(Icons.chevron_right),
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
