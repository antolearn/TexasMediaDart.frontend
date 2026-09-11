class UserProfile {
  const UserProfile({required this.userId, required this.email});

  final String userId;
  final String email;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email};
  }
}
