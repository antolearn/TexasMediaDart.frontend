import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../identity/services/auth_service.dart';
import '../models/current_organization.dart';

class OrganizationDeactivatedPage extends StatefulWidget {
  const OrganizationDeactivatedPage({this.organization, super.key});

  final CurrentOrganization? organization;

  @override
  State<OrganizationDeactivatedPage> createState() =>
      _OrganizationDeactivatedPageState();
}

class _OrganizationDeactivatedPageState
    extends State<OrganizationDeactivatedPage> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    final authService = context.read<AuthService>();

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await authService.logout();
    } finally {
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Not available';
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
    final organization = widget.organization;

    final organizationName = organization?.name.trim().isNotEmpty == true
        ? organization!.name
        : 'Your organization';

    final deactivatedBy = organization?.modifiedBy?.trim().isNotEmpty == true
        ? organization!.modifiedBy!
        : 'Not available';

    final deactivatedUtc = organization?.modifiedUtc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TexasMediaDart'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.block,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Organization Deactivated',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '$organizationName has been deactivated.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 32),

                    _buildInformationField(
                      context,
                      icon: Icons.person_outline,
                      label: 'Deactivated By',
                      value: deactivatedBy,
                    ),

                    const SizedBox(height: 16),

                    _buildInformationField(
                      context,
                      icon: Icons.schedule,
                      label: 'Deactivated Date / Time',
                      value: _formatDateTime(deactivatedUtc),
                    ),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.support_agent, size: 32),
                          SizedBox(height: 12),
                          Text(
                            'Need Help?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please contact support@vetridart.com '
                            'to have your organization re-enabled.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton.icon(
                        onPressed: _isLoggingOut ? null : _logout,
                        icon: _isLoggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: Text(
                          _isLoggingOut ? 'Logging out...' : 'Logout',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),

                const SizedBox(height: 4),

                SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
