class HealthStatus {
  final String status;
  final String database;
  final DateTime timestampUtc;

  const HealthStatus({
    required this.status,
    required this.database,
    required this.timestampUtc,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String,
      database: json['database'] as String,
      timestampUtc: DateTime.parse(json['timestampUtc'] as String),
    );
  }
}
