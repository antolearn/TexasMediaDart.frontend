import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/network/api_exception.dart';
import '../controllers/module_permissions_controller.dart';
import '../models/current_organization.dart';
import '../services/organization_service.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CurrentOrganization? _organization;

  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_handleFormChanged);

    _loadOrganization();
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleFormChanged);
    _nameController.dispose();

    super.dispose();
  }

  void _handleFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasChanges {
    final organization = _organization;

    if (organization == null) {
      return false;
    }

    return _nameController.text.trim() != organization.name ||
        _isActive != organization.isActive;
  }

  bool _canUpdateOrganization(BuildContext context) {
    final permissionsController = context.read<ModulePermissionsController>();

    return permissionsController.canUpdate('ORGANIZATION');
  }

  Future<void> _loadOrganization() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final organizationService = context.read<OrganizationService>();

      final organization = await organizationService.getCurrentOrganization();

      if (!mounted) {
        return;
      }

      if (organization == null) {
        setState(() {
          _organization = null;
          _errorMessage = 'Organization was not found.';
        });

        return;
      }

      setState(() {
        _organization = organization;
        _nameController.text = organization.name;
        _isActive = organization.isActive;
      });
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _organization = null;
        _errorMessage = exception.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _organization = null;
        _errorMessage = 'Unable to load the organization. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _confirmDeactivation() async {
    if (!mounted) {
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: const Text('Deactivate Organization?'),
          content: const Text(
            'Deactivating this organization will prevent users from '
            'accessing the organization. Are you sure you want to continue?',
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
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _saveOrganization() async {
    if (_isSaving || !_hasChanges) {
      return;
    }

    if (!_canUpdateOrganization(context)) {
      setState(() {
        _errorMessage =
            'You do not have permission to update organization settings.';
      });

      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentOrganization = _organization;

    if (currentOrganization == null) {
      return;
    }

    final isDeactivating = currentOrganization.isActive && !_isActive;

    if (isDeactivating) {
      final confirmed = await _confirmDeactivation();

      if (!mounted) {
        return;
      }

      if (!confirmed) {
        setState(() {
          _isActive = currentOrganization.isActive;
        });

        return;
      }
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final organizationService = context.read<OrganizationService>();

      final updatedOrganization = await organizationService
          .updateCurrentOrganization(
            name: _nameController.text.trim(),
            isActive: _isActive,
          );

      if (!mounted) {
        return;
      }

      //
      // Organization was deactivated.
      //
      if (!updatedOrganization.isActive) {
        final permissionsController = context
            .read<ModulePermissionsController>();

        permissionsController.clear();

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.organizationDeactivated,
          (route) => false,
          arguments: updatedOrganization,
        );

        return;
      }

      //
      // Organization remains active.
      //
      setState(() {
        _organization = updatedOrganization;
        _nameController.text = updatedOrganization.name;
        _isActive = updatedOrganization.isActive;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Organization updated successfully.')),
        );
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = exception.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to update the organization. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '—';
    }

    final local = value.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${local.year}-'
        '${twoDigits(local.month)}-'
        '${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}:'
        '${twoDigits(local.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _organization == null) {
      return _buildError(context);
    }

    final organization = _organization;

    if (organization == null) {
      return const Center(child: Text('Organization was not found.'));
    }

    return _buildOrganizationSettings(context, organization);
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to Load Organization',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _loadOrganization,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationSettings(
    BuildContext context,
    CurrentOrganization organization,
  ) {
    return DefaultTabController(
      length: 1,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Organization Settings',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your organization, users, roles, '
                      'properties, and related settings.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // ---------------------------------------------
                    // Header / Primary Tabs
                    //
                    // Future:
                    // Organization | Users | Roles | Properties
                    // ---------------------------------------------
                    const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(icon: Icon(Icons.business), text: 'Organization'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildOrganizationSection(context, organization),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationSection(
    BuildContext context,
    CurrentOrganization organization,
  ) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(Icons.tune), text: 'General'),
              Tab(icon: Icon(Icons.history), text: 'Audit'),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 520,
            child: TabBarView(
              children: [
                _buildGeneralTab(context, organization),
                _buildAuditTab(context, organization),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(
    BuildContext context,
    CurrentOrganization organization,
  ) {
    final canUpdate = _canUpdateOrganization(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'General Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage the basic information and status of your organization.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (!canUpdate) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have read-only access to organization settings.',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              enabled: canUpdate && !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                hintText: 'Enter organization name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';

                if (name.isEmpty) {
                  return 'Organization name is required.';
                }

                if (name.length < 2) {
                  return 'Organization name must be at least 2 characters.';
                }

                if (name.length > 200) {
                  return 'Organization name cannot exceed 200 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            Card(
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Organization Active'),
                subtitle: Text(
                  _isActive
                      ? 'This organization is active.'
                      : 'This organization is inactive.',
                ),
                value: _isActive,
                onChanged: !canUpdate || _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
              ),
            ),

            const SizedBox(height: 24),

            _buildReadOnlyField(
              label: 'Organization ID',
              value: organization.organizationId,
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: !canUpdate || _isSaving || !_hasChanges
                    ? null
                    : _saveOrganization,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTab(
    BuildContext context,
    CurrentOrganization organization,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Audit Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'View the creation and modification history '
            'for this organization.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          _buildReadOnlyField(
            label: 'Created By',
            value: organization.createdBy,
          ),

          const SizedBox(height: 16),

          _buildReadOnlyField(
            label: 'Created Date / Time',
            value: _formatDateTime(organization.createdUtc),
          ),

          const SizedBox(height: 16),

          _buildReadOnlyField(
            label: 'Modified By',
            value: organization.modifiedBy ?? '—',
          ),

          const SizedBox(height: 16),

          _buildReadOnlyField(
            label: 'Modified Date / Time',
            value: _formatDateTime(organization.modifiedUtc),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enableInteractiveSelection: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}
