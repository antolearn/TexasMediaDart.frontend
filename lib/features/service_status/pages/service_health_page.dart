import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../models/service_health.dart';
import '../services/service_health_status.dart';

class ServiceHealthPage extends StatefulWidget {
  const ServiceHealthPage({super.key});

  @override
  State<ServiceHealthPage> createState() => _ServiceHealthPageState();
}

class _ServiceHealthPageState extends State<ServiceHealthPage> {
  final ServiceHealthService _healthService = ServiceHealthService();

  late List<ServiceHealth> _services;

  bool _checkingAll = false;

  @override
  void initState() {
    super.initState();

    _services = [
      ServiceHealth(serviceName: 'Main', apiUrl: AppConfig.apiBaseUrl),
      ServiceHealth(
        serviceName: 'Identity',
        apiUrl: AppConfig.identityApiBaseUrl,
      ),
      ServiceHealth(
        serviceName: 'Organization',
        apiUrl: AppConfig.organizationApiBaseUrl,
      ),
    ];
  }

  Future<void> _checkService(int index) async {
    final service = _services[index];

    setState(() {
      _services[index] = service.copyWith(isChecking: true, errorMessage: null);
    });

    final result = await _healthService.checkService(
      serviceName: service.serviceName,
      apiUrl: service.apiUrl,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _services[index] = result.copyWith(isChecking: false);
    });
  }

  Future<void> _checkAll() async {
    setState(() {
      _checkingAll = true;
    });

    try {
      for (var index = 0; index < _services.length; index++) {
        await _checkService(index);
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingAll = false;
        });
      }
    }
  }

  Widget _status(bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value ? Icons.check_circle : Icons.remove_circle_outline,
          size: 18,
          color: value ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(value ? 'OK' : 'Not checked'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Health Status')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment: ${AppConfig.environment.toUpperCase()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Frontend Version: ${AppConfig.frontendVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Service')),
                    DataColumn(label: Text('API')),
                    DataColumn(label: Text('Database')),
                    DataColumn(label: Text('Database Name')),
                    DataColumn(label: Text('DB Version')),
                    DataColumn(label: Text('API Version')),
                    DataColumn(label: Text('API URL')),
                    DataColumn(label: Text('Check')),
                  ],
                  rows: List.generate(_services.length, (index) {
                    final service = _services[index];

                    return DataRow(
                      cells: [
                        DataCell(Text(service.serviceName)),
                        DataCell(_status(service.apiOk)),
                        DataCell(_status(service.databaseOk)),
                        DataCell(Text(service.databaseName ?? '—')),
                        DataCell(Text(service.databaseVersion ?? '—')),
                        DataCell(Text(service.version ?? '—')),
                        DataCell(SelectableText(service.apiUrl)),
                        DataCell(
                          service.isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : FilledButton(
                                  onPressed: _checkingAll
                                      ? null
                                      : () => _checkService(index),
                                  child: const Text('Check'),
                                ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: FilledButton.icon(
                onPressed: _checkingAll ? null : _checkAll,
                icon: _checkingAll
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.health_and_safety),
                label: Text(
                  _checkingAll ? 'Checking...' : 'Check Health Status for All',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
