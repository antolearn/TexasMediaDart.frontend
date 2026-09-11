class RegisterResponse {
  const RegisterResponse({required this.userId, required this.email});

  final String userId;
  final String email;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email};
  }
}
