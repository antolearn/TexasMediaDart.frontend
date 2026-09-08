class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:7001',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'local',
  );

  static bool get isLocal => environment == 'local';

  static bool get isDev => environment == 'dev';

  static bool get isProd => environment == 'prod';
}
