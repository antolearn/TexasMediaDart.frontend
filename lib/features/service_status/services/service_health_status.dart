import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/service_health.dart';

class ServiceHealthService {
  Future<ServiceHealth> checkService({
    required String serviceName,
    required String apiUrl,
  }) async {
    bool apiOk = false;
    bool databaseOk = false;

    String? databaseName;
    String? databaseVersion;
    String? apiVersion;
    String? errorMessage;
    //
    // Check API health
    //
    try {
      final apiResponse = await http.get(Uri.parse('$apiUrl/health/api'));

      if (apiResponse.statusCode == 200) {
        final apiJson = jsonDecode(apiResponse.body) as Map<String, dynamic>;

        final status = apiJson['status']?.toString().toLowerCase();

        apiOk = status == 'healthy';
      } else {
        apiOk = false;
        errorMessage =
            'API health check failed. '
            'HTTP ${apiResponse.statusCode}';
      }
    } catch (exception) {
      apiOk = false;
      errorMessage = 'API health check error: $exception';
    }
    //
    // Check database health
    //
    try {
      final dbResponse = await http.get(Uri.parse('$apiUrl/health/db'));

      // Receiving an HTTP response means the API is reachable.
      apiOk = true;

      if (dbResponse.statusCode == 200) {
        final dbJson = jsonDecode(dbResponse.body) as Map<String, dynamic>;

        final status = dbJson['status']?.toString().toLowerCase();

        databaseOk = status == 'healthy';
        databaseName = dbJson['database']?.toString();
        databaseVersion = dbJson['databaseVersion']?.toString();
      } else {
        databaseOk = false;
        errorMessage =
            'Database health check failed. '
            'HTTP ${dbResponse.statusCode}';
      }
    } catch (exception) {
      errorMessage = 'Database health check error: $exception';
    }

    //
    // Check API version independently
    //
    try {
      final versionResponse = await http.get(
        Uri.parse('$apiUrl/health/version'),
      );

      // Receiving a response confirms the API is reachable.
      apiOk = true;

      if (versionResponse.statusCode == 200) {
        final versionJson =
            jsonDecode(versionResponse.body) as Map<String, dynamic>;

        apiVersion = versionJson['version']?.toString();
      } else {
        errorMessage ??=
            'API version check failed. '
            'HTTP ${versionResponse.statusCode}';
      }
    } catch (exception) {
      errorMessage ??= 'API health check error: $exception';
    }

    return ServiceHealth(
      serviceName: serviceName,
      apiUrl: apiUrl,
      apiOk: apiOk,
      databaseOk: databaseOk,
      databaseName: databaseName,
      databaseVersion: databaseVersion,
      version: apiVersion,
      errorMessage: errorMessage,
    );
  }
}
