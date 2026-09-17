class ServiceHealth {
  const ServiceHealth({
    required this.serviceName,
    required this.apiUrl,
    this.apiOk = false,
    this.databaseOk = false,
    this.databaseName,
    this.databaseVersion,
    this.version,
    this.errorMessage,
    this.isChecking = false,
  });

  final String serviceName;
  final String apiUrl;

  final bool apiOk;
  final bool databaseOk;

  final String? databaseName;
  final String? databaseVersion;
  final String? version;
  final String? errorMessage;

  final bool isChecking;

  ServiceHealth copyWith({
    String? serviceName,
    String? apiUrl,
    bool? apiOk,
    bool? databaseOk,
    String? databaseName,
    String? databaseVersion,
    String? version,
    String? errorMessage,
    bool? isChecking,
  }) {
    return ServiceHealth(
      serviceName: serviceName ?? this.serviceName,
      apiUrl: apiUrl ?? this.apiUrl,
      apiOk: apiOk ?? this.apiOk,
      databaseOk: databaseOk ?? this.databaseOk,
      databaseName: databaseName ?? this.databaseName,
      databaseVersion: databaseVersion ?? this.databaseVersion,
      version: version ?? this.version,
      errorMessage: errorMessage,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}
