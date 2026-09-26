class UserGroupMember {
  const UserGroupMember({
    required this.userGroupId,
    required this.organizationUserId,
    required this.identityUserId,
    required this.isActive,
    required this.isApproved,
    required this.membershipCreatedBy,
    required this.membershipCreatedUtc,
  });

  final String userGroupId;
  final int organizationUserId;
  final String identityUserId;
  final bool isActive;
  final bool isApproved;
  final String membershipCreatedBy;
  final DateTime membershipCreatedUtc;

  factory UserGroupMember.fromJson(Map<String, dynamic> json) {
    return UserGroupMember(
      userGroupId: json['userGroupId']?.toString() ?? '',
      organizationUserId: (json['organizationUserId'] as num?)?.toInt() ?? 0,
      identityUserId: json['identityUserId']?.toString() ?? '',
      isActive: json['isActive'] == true,
      isApproved: json['isApproved'] == true,
      membershipCreatedBy: json['membershipCreatedBy']?.toString() ?? '',
      membershipCreatedUtc: DateTime.parse(
        json['membershipCreatedUtc'].toString(),
      ),
    );
  }
}
