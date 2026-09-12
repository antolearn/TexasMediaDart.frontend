import '../../../core/network/api_client.dart';
import '../models/health_status.dart';

class HealthService {
  HealthService({required this._apiClient});

  final ApiClient _apiClient;

  Future<HealthStatus> getDatabaseHealth() async {
    final response = await _apiClient.get('/health/db');

    if (response is! Map<String, dynamic>) {
      throw Exception('Unexpected response format from /health/db');
    }

    return HealthStatus.fromJson(response);
  }
}
