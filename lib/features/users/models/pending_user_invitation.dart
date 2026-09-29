class PendingUserInvitation {
  const PendingUserInvitation({
    required this.invitationId,
    required this.email,
    required this.organizationId,
    required this.invitedByIdentityUserId,
    required this.expiresUtc,
    required this.createdUtc,
  });

  final String invitationId;
  final String email;
  final String organizationId;
  final String invitedByIdentityUserId;
  final DateTime expiresUtc;
  final DateTime createdUtc;

  factory PendingUserInvitation.fromJson(Map<String, dynamic> json) {
    return PendingUserInvitation(
      invitationId: json['invitationId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      invitedByIdentityUserId: json['invitedByIdentityUserId'] as String? ?? '',
      expiresUtc: DateTime.parse(json['expiresUtc'] as String),
      createdUtc: DateTime.parse(json['createdUtc'] as String),
    );
  }
}
