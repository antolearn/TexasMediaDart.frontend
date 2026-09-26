import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../organization/controllers/module_permissions_controller.dart';
import '../controllers/user_groups_controller.dart';
import '../models/user_group.dart';
import '../widgets/add_user_group_dialog.dart';
import '../widgets/delete_user_group_dialog.dart';
import '../widgets/edit_user_group_dialog.dart';
import '../widgets/user_group_filters.dart';
import '../widgets/user_groups_pagination.dart';
import '../widgets/user_groups_table.dart';

class UserGroupsPage extends StatefulWidget {
  const UserGroupsPage({super.key});

  @override
  State<UserGroupsPage> createState() => _UserGroupsPageState();
}

class _UserGroupsPageState extends State<UserGroupsPage> {
  final TextEditingController _searchController = TextEditingController();

  bool? _selectedIsActive = true;
  bool? _selectedIsApproved;
  bool _includeDeleted = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserGroupsController>();
    final permissions = context.watch<ModulePermissionsController>();

    final canCreate = permissions.canCreate('USER_GROUPS');
    final canUpdate = permissions.canUpdate('USER_GROUPS');
    final canDelete = permissions.canDelete('USER_GROUPS');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(controller, canCreate: canCreate),
          const SizedBox(height: 20),
          UserGroupFilters(
            searchController: _searchController,
            selectedIsActive: _selectedIsActive,
            selectedIsApproved: _selectedIsApproved,
            includeDeleted: _includeDeleted,
            isLoading: controller.isLoading,
            onStatusChanged: (value) {
              setState(() {
                _selectedIsActive = value;
              });
            },
            onApprovalChanged: (value) {
              setState(() {
                _selectedIsApproved = value;
              });
            },
            onIncludeDeletedChanged: (value) {
              setState(() {
                _includeDeleted = value;
              });
            },
            onApply: () {
              _applyFilters(controller);
            },
            onClear: () {
              _clearFilters(controller);
            },
          ),
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
    UserGroupsController controller, {
    required bool canCreate,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Groups',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Manage organization user groups and memberships.',
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
                : () => _showAddUserGroupDialog(controller),
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
      ],
    );
  }

  Future<void> _applyFilters(UserGroupsController controller) async {
    await controller.applyFilters(
      searchText: _searchController.text.trim(),
      isActive: _selectedIsActive,
      isApproved: _selectedIsApproved,
      includeDeleted: _includeDeleted,
    );
  }

  void _clearFilters(UserGroupsController controller) {
    _searchController.clear();

    setState(() {
      _selectedIsActive = true;
      _selectedIsApproved = null;
      _includeDeleted = false;
    });

    controller.clearFilters();
  }

  Future<void> _showAddUserGroupDialog(UserGroupsController controller) async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddUserGroupDialog(),
    );

    if (!mounted || created != true) {
      return;
    }

    await controller.refreshAfterCreate();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User group created successfully.')),
    );
  }

  Future<void> _showEditUserGroupDialog(
    UserGroup userGroup,
    UserGroupsController controller,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditUserGroupDialog(userGroup: userGroup),
    );

    if (!mounted || updated != true) {
      return;
    }

    await controller.refreshAfterUpdate();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User group updated successfully.')),
    );
  }

  Future<void> _showDeleteUserGroupDialog(
    UserGroup userGroup,
    UserGroupsController controller,
  ) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteUserGroupDialog(userGroup: userGroup),
    );

    if (!mounted || deleted != true) {
      return;
    }

    await controller.refreshAfterDelete();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User group deleted successfully.')),
    );
  }

  Widget _buildContent(
    UserGroupsController controller, {
    required bool canUpdate,
    required bool canDelete,
  }) {
    if (!controller.hasSearched) {
      return _buildInitialSearchState();
    }

    if (controller.isLoading && controller.userGroups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.hasError) {
      return _buildError(controller);
    }

    if (controller.userGroups.isEmpty) {
      return _buildNoResults();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: UserGroupsTable(
            userGroups: controller.userGroups,
            canUpdate: canUpdate,
            canDelete: canDelete,
            sortBy: controller.sortBy,
            sortAscending: controller.sortAscending,
            onSort: (sortBy, ascending) {
              controller.sortByColumn(sortBy, ascending);
            },
            onEdit: (userGroup) {
              _showEditUserGroupDialog(userGroup, controller);
            },
            onDelete: (userGroup) {
              _showDeleteUserGroupDialog(userGroup, controller);
            },
          ),
        ),
        const SizedBox(height: 16),
        UserGroupsPagination(controller: controller),
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
            'Search for user groups',
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
            'No user groups found.',
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

  Widget _buildError(UserGroupsController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'Unable to load user groups.',
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
