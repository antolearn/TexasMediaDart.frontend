import 'package:flutter/foundation.dart';

import '../models/health_status.dart';
import '../services/health_service.dart';

class HomeController extends ChangeNotifier {
  final HealthService _healthService;

  HomeController({HealthService? healthService})
    : _healthService = healthService ?? HealthService();

  bool _isLoading = false;
  HealthStatus? _healthStatus;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  HealthStatus? get healthStatus => _healthStatus;
  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get isHealthy => _healthStatus?.status.toLowerCase() == 'healthy';

  Future<void> loadHealthStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthStatus = await _healthService.getDatabaseHealth();
    } catch (error) {
      _healthStatus = null;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
