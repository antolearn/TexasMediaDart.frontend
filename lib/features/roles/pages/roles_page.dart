import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../organization/controllers/module_permissions_controller.dart';
import '../controllers/roles_controller.dart';
import '../models/role.dart';
import '../widgets/add_role_dialog.dart';
import '../widgets/delete_role_dialog.dart';
import '../widgets/edit_role_dialog.dart';
import '../widgets/role_audit_dialog.dart';
import '../widgets/role_filters.dart';
import '../widgets/role_permissions_dialog.dart';
import '../widgets/roles_pagination.dart';
import '../widgets/roles_table.dart';

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
          _buildHeader(controller, canCreate: canCreate),
          const SizedBox(height: 20),
          RoleFilters(
            searchController: _searchController,
            selectedIsActive: _selectedIsActive,
            includeDeleted: _includeDeleted,
            isLoading: controller.isLoading,
            onStatusChanged: (value) {
              setState(() {
                _selectedIsActive = value;
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

  Widget _buildHeader(RolesController controller, {required bool canCreate}) {
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

  Future<void> _showRoleAuditDialog(Role role) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return RoleAuditDialog(role: role);
      },
    );
  }

  Future<void> _showRolePermissionsDialog(Role role) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return RolePermissionsDialog(role: role);
      },
    );

    if (!mounted || updated != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Role permissions updated successfully.')),
    );
  }

  Future<void> _showAddRoleDialog(RolesController controller) async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AddRoleDialog(controller: controller);
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
        return EditRoleDialog(controller: controller, role: role);
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
        return DeleteRoleDialog(role: role);
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
          child: RolesTable(
            roles: controller.roles,
            canUpdate: canUpdate,
            canDelete: canDelete,

            // Server-side sorting.
            sortBy: controller.sortBy,
            sortAscending: controller.sortAscending,
            onSort: (sortBy, ascending) {
              controller.sortByColumn(sortBy, ascending);
            },

            // Audit is read-only and available for every role.
            onAudit: (role) {
              _showRoleAuditDialog(role);
            },

            // View or manage role permissions.
            onPermissions: (role) {
              _showRolePermissionsDialog(role);
            },

            onEdit: (role) {
              _showEditRoleDialog(role, controller);
            },

            onDelete: (role) {
              _showDeleteRoleDialog(role, controller);
            },
          ),
        ),
        const SizedBox(height: 16),
        RolesPagination(controller: controller),
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
}
