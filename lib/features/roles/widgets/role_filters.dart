import 'package:flutter/material.dart';

class RoleFilters extends StatelessWidget {
  const RoleFilters({
    super.key,
    required this.searchController,
    required this.selectedIsActive,
    required this.includeDeleted,
    required this.isLoading,
    required this.onStatusChanged,
    required this.onIncludeDeletedChanged,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController searchController;
  final bool? selectedIsActive;
  final bool includeDeleted;
  final bool isLoading;

  final ValueChanged<bool?> onStatusChanged;
  final ValueChanged<bool> onIncludeDeletedChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: TextField(
            controller: searchController,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'Search roles',
              hintText: 'Role name or description',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onApply(),
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<bool?>(
            initialValue: selectedIsActive,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<bool?>(value: null, child: Text('All')),
              DropdownMenuItem<bool?>(value: true, child: Text('Active')),
              DropdownMenuItem<bool?>(value: false, child: Text('Inactive')),
            ],
            onChanged: isLoading ? null : onStatusChanged,
          ),
        ),
        SizedBox(
          width: 180,
          child: CheckboxListTile(
            value: includeDeleted,
            onChanged: isLoading
                ? null
                : (value) {
                    onIncludeDeletedChanged(value ?? false);
                  },
            title: const Text('Include deleted'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        FilledButton.icon(
          onPressed: isLoading ? null : onApply,
          icon: const Icon(Icons.search),
          label: const Text('Apply'),
        ),
        TextButton.icon(
          onPressed: isLoading ? null : onClear,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
        ),
      ],
    );
  }
}
