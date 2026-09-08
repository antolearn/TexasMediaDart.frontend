import '../../../core/network/api_client.dart';
import '../models/health_status.dart';

class HealthService {
  final ApiClient _apiClient;

  HealthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<HealthStatus> getDatabaseHealth() async {
    final response = await _apiClient.get('/health/db');

    if (response is! Map<String, dynamic>) {
      throw Exception('Unexpected response format from /health/db');
    }

    return HealthStatus.fromJson(response);
  }
}
