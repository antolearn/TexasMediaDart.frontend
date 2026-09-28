class UserInvitation {
  const UserInvitation({
    required this.invitationId,
    required this.email,
    required this.organizationId,
    required this.expiresUtc,
    required this.invitationToken,
  });

  final String invitationId;
  final String email;
  final String organizationId;
  final DateTime expiresUtc;
  final String invitationToken;

  factory UserInvitation.fromJson(Map<String, dynamic> json) {
    return UserInvitation(
      invitationId: json['invitationId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      expiresUtc: DateTime.parse(json['expiresUtc'] as String),
      invitationToken: json['invitationToken'] as String? ?? '',
    );
  }
}
