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
  final TextEditingController _emailController = TextEditingController();

  bool? _selectedIsActive = true;
  bool? _selectedIsApproved;

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
          tooltip: 'Refresh search results',
          onPressed: controller.hasSearched && !controller.isLoading
              ? controller.refresh
              : null,
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

  Widget _buildFilters(UsersController controller) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: _emailController,
            enabled: !controller.isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Search by email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) {
              if (!controller.isLoading) {
                _applyFilters(controller);
              }
            },
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<bool?>(
            initialValue: _selectedIsActive,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
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
          width: 220,
          child: DropdownButtonFormField<bool?>(
            initialValue: _selectedIsApproved,
            decoration: const InputDecoration(
              labelText: 'Approval',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem<bool?>(value: null, child: Text('All')),
              DropdownMenuItem<bool?>(value: true, child: Text('Approved')),
              DropdownMenuItem<bool?>(
                value: false,
                child: Text('Not approved'),
              ),
            ],
            onChanged: controller.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedIsApproved = value;
                    });
                  },
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
          icon: const Icon(Icons.close),
          label: const Text('Clear'),
        ),
      ],
    );
  }

  Future<void> _applyFilters(UsersController controller) async {
    await controller.applyFilters(
      email: _emailController.text,
      isActive: _selectedIsActive,
      isApproved: _selectedIsApproved,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearFilters(UsersController controller) {
    _emailController.clear();

    setState(() {
      _selectedIsActive = true;
      _selectedIsApproved = null;
    });

    controller.clearFilters();
  }

  Widget _buildContent(
    UsersController controller, {
    required bool canUpdate,
    required bool canDelete,
  }) {
    if (!controller.hasSearched) {
      return _buildInitialSearchState();
    }

    if (controller.isLoading && controller.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return _buildError(controller);
    }

    if (controller.users.isEmpty) {
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
                  sortColumnIndex: 6,
                  sortAscending: controller.sortAscending,
                  columns: [
                    const DataColumn(label: Text('ID')),
                    const DataColumn(label: Text('Email')),
                    const DataColumn(label: Text('Active')),
                    const DataColumn(label: Text('Approved')),
                    const DataColumn(label: Text('Account Active')),
                    const DataColumn(label: Text('Email Verified')),
                    DataColumn(
                      label: const Text('Created'),
                      onSort: (_, ascending) {
                        controller.sortByCreatedUtc(ascending);
                      },
                    ),
                    const DataColumn(label: Text('Actions')),
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

  Widget _buildInitialSearchState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_search, size: 56, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          const Text(
            'Search for users',
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
            'No users found.',
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
            falseLabel: 'Not approved',
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

  Widget _buildPagination(UsersController controller) {
    return Row(
      children: [
        Text(
          '${controller.totalCount} '
          '${controller.totalCount == 1 ? 'record' : 'records'}',
        ),
        const Spacer(),
        const Text('Rows per page:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: controller.pageSize,
          items: UsersController.allowedPageSizes
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
        if (controller.totalPages > 1) ...[
          const SizedBox(width: 24),
          Text(
            'Page ${controller.pageNumber} '
            'of ${controller.totalPages}',
          ),
          const SizedBox(width: 8),
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
            onPressed: controller.isLoading ? null : controller.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
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
