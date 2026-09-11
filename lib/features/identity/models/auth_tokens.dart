class AuthTokens {
  const AuthTokens({
    required this.userId,
    required this.email,
    required this.accessToken,
    required this.expiresAtUtc,
    required this.refreshToken,
    required this.refreshTokenExpiresAtUtc,
  });

  final String userId;
  final String email;
  final String accessToken;
  final DateTime expiresAtUtc;
  final String refreshToken;
  final DateTime refreshTokenExpiresAtUtc;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      expiresAtUtc: DateTime.parse(json['expiresAtUtc']?.toString() ?? ''),
      refreshToken: json['refreshToken']?.toString() ?? '',
      refreshTokenExpiresAtUtc: DateTime.parse(
        json['refreshTokenExpiresAtUtc']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'accessToken': accessToken,
      'expiresAtUtc': expiresAtUtc.toIso8601String(),
      'refreshToken': refreshToken,
      'refreshTokenExpiresAtUtc': refreshTokenExpiresAtUtc.toIso8601String(),
    };
  }

  bool get isAccessTokenExpired => DateTime.now().toUtc().isAfter(expiresAtUtc);

  bool get isRefreshTokenExpired =>
      DateTime.now().toUtc().isAfter(refreshTokenExpiresAtUtc);
}
