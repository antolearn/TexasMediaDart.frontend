class VerifyEmailResponse {
  const VerifyEmailResponse({
    required this.userId,
    required this.email,
    required this.isEmailVerified,
  });

  final String userId;
  final String email;
  final bool isEmailVerified;

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
    );
  }
}
