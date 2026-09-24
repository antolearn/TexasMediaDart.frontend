import 'package:flutter/material.dart';

import '../models/role.dart';
import 'role_status_indicator.dart';

class RoleAuditDialog extends StatelessWidget {
  const RoleAuditDialog({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history),
          const SizedBox(width: 8),
          Expanded(child: Text('Role Audit - ${role.name}')),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionTitle('Role Information'),
              const SizedBox(height: 12),

              _buildAuditRow(label: 'Role Name', value: role.name),
              _buildAuditRow(
                label: 'Description',
                value: _displayValue(role.description),
              ),
              _buildAuditRow(
                label: 'Role Type',
                value: role.isSystemRole ? 'System' : 'Custom',
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              _buildSectionTitle('Current Status'),
              const SizedBox(height: 12),

              _buildStatusRow(
                label: 'Active',
                value: role.isActive,
                trueLabel: 'Active',
                falseLabel: 'Inactive',
              ),
              _buildStatusRow(
                label: 'Approved',
                value: role.isApproved,
                trueLabel: 'Approved',
                falseLabel: 'Not approved',
              ),
              _buildStatusRow(
                label: 'Deleted',
                value: role.isDeleted,
                trueLabel: 'Deleted',
                falseLabel: 'Not deleted',
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              _buildSectionTitle('Audit Information'),
              const SizedBox(height: 12),

              _buildAuditRow(
                label: 'Created By',
                value: _displayValue(role.createdBy),
              ),
              _buildAuditRow(
                label: 'Created',
                value: _formatDateTime(role.createdUtc),
              ),
              _buildAuditRow(
                label: 'Modified By',
                value: _displayValue(role.modifiedBy),
              ),
              _buildAuditRow(
                label: 'Modified',
                value: role.modifiedUtc == null
                    ? '-'
                    : _formatDateTime(role.modifiedUtc!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildAuditRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required bool value,
    required String trueLabel,
    required String falseLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          RoleStatusIndicator(
            value: value,
            trueLabel: trueLabel,
            falseLabel: falseLabel,
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value.trim();
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
