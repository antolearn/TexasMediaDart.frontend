import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../organization/controllers/module_permissions_controller.dart';
import '../controllers/users_controller.dart';
import '../models/create_user_result.dart';
import '../models/organization_user.dart';
import '../models/pending_user_invitation.dart';
import '../widgets/add_user_dialog.dart';

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<UsersController>().loadPendingInvitations();
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
          _buildHeader(controller, canCreate: canCreate),
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

  Widget _buildHeader(UsersController controller, {required bool canCreate}) {
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
          OutlinedButton.icon(
            onPressed: controller.isLoadingPendingInvitations
                ? null
                : () => _showPendingInvitationsDialog(controller),
            icon: controller.isLoadingPendingInvitations
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.mark_email_unread_outlined),
            label: Text(
              'Pending Invitations '
              '(${controller.pendingInvitations.length})',
            ),
          ),
        if (canCreate) const SizedBox(width: 8),
        if (canCreate)
          FilledButton.icon(
            onPressed: controller.isAddingUser ? null : _showAddUserDialog,
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

  Future<void> _showAddUserDialog() async {
    final result = await showDialog<CreateUserResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddUserDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    String message;

    if (result.wasAdded) {
      final email =
          result.user?.email ??
          result.user?.identityUserId.toString() ??
          'User';

      message = '$email added successfully.';
    } else if (result.wasInvited) {
      final email = result.invitation?.email ?? 'User';

      message = 'Invitation created for $email.';
    } else {
      message = 'User request completed successfully.';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPendingInvitationsDialog(UsersController controller) async {
    await controller.loadPendingInvitations();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer<UsersController>(
          builder: (context, controller, _) {
            return AlertDialog(
              title: Row(
                children: [
                  const Expanded(child: Text('Pending Invitations')),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: controller.isLoadingPendingInvitations
                        ? null
                        : controller.loadPendingInvitations,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              content: SizedBox(
                width: 850,
                child: _buildPendingInvitationsContent(controller),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPendingInvitationsContent(UsersController controller) {
    if (controller.isLoadingPendingInvitations &&
        controller.pendingInvitations.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.hasPendingInvitationsError) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                controller.pendingInvitationsErrorMessage ??
                    'Unable to load pending invitations.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.isLoadingPendingInvitations
                    ? null
                    : controller.loadPendingInvitations,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.pendingInvitations.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 44,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No pending invitations.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Invited')),
            DataColumn(label: Text('Expires')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.pendingInvitations.map((invitation) {
            final isResending =
                controller.resendingInvitationId == invitation.invitationId;

            return DataRow(
              cells: [
                DataCell(Text(invitation.email)),
                DataCell(Text(_formatDateTime(invitation.createdUtc))),
                DataCell(Text(_formatDateTime(invitation.expiresUtc))),
                DataCell(
                  FilledButton.tonalIcon(
                    onPressed: controller.resendingInvitationId != null
                        ? null
                        : () => _resendInvitation(controller, invitation),
                    icon: isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined, size: 18),
                    label: Text(isResending ? 'Sending...' : 'Resend'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _resendInvitation(
    UsersController controller,
    PendingUserInvitation invitation,
  ) async {
    try {
      await controller.resendInvitation(invitation);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitation resent to '
            '${invitation.email}.',
          ),
        ),
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to resend invitation: '
            '$exception',
          ),
        ),
      );
    }
  }

  Future<void> _applyFilters(UsersController controller) async {
    await controller.applyFilters(
      email: _emailController.text,
      isActive: _selectedIsActive,
      isApproved: _selectedIsApproved,
    );
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
            'Select your search criteria and '
            'click Apply.',
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
