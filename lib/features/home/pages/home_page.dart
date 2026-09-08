import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('TexasMediaDart')),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to TexasMediaDart Inc.',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                _buildHealthStatus(controller),
              ],
            ),
          ),

          if (!AppConfig.isProd)
            Positioned(
              left: 12,
              bottom: 12,
              child: Text(
                'Environment: ${AppConfig.environment}\n'
                'API: ${AppConfig.apiBaseUrl}\n'
                'Frontend Version: ${AppConfig.frontendVersion}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthStatus(HomeController controller) {
    if (controller.isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Checking API connection...'),
        ],
      );
    }

    if (controller.hasError) {
      return Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 8),
          const Text(
            'Unable to connect to API',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final health = controller.healthStatus;

    if (health == null) {
      return const Text('Health status unavailable');
    }

    return Column(
      children: [
        Icon(
          controller.isHealthy ? Icons.check_circle : Icons.warning,
          size: 40,
          color: controller.isHealthy ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 12),
        Text(
          'API Status: ${controller.isHealthy ? 'Connected' : 'Unavailable'}',
        ),
        const SizedBox(height: 6),
        Text('Database: ${health.database}'),
        const SizedBox(height: 6),
        Text('Database Status: ${health.status}'),
      ],
    );
  }
}
