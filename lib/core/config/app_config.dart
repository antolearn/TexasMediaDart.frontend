import 'dart:convert';

import 'package:http/http.dart' as http;

class AppConfig {
  static String environment = 'local';

  static String apiBaseUrl = 'http://localhost:5295';

  static String identityApiBaseUrl = 'http://localhost:5248';
  static String organizationApiBaseUrl = 'http://localhost:5110';

  static const String frontendVersion = String.fromEnvironment(
    'FRONTEND_VERSION',
    defaultValue: 'local',
  );

  static Future<void> initialize() async {
    final configUri = Uri.base.resolve('config.json');

    final response = await http.get(configUri);

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load runtime configuration. '
        'HTTP status: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    environment = json['environment']?.toString() ?? 'local';

    apiBaseUrl = json['apiBaseUrl']?.toString() ?? 'http://localhost:5295';

    identityApiBaseUrl =
        json['identityApiBaseUrl']?.toString() ?? 'http://localhost:5248';
    organizationApiBaseUrl =
        json['organizationApiBaseUrl']?.toString() ?? 'http://localhost:5110';
  }

  static bool get isLocal => environment == 'local';

  static bool get isDev => environment == 'dev';

  static bool get isProd => environment == 'prod';
}
