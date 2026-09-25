class UserGroup {
  const UserGroup({
    required this.userGroupId,
    required this.organizationId,
    required this.name,
    this.description,
    required this.isActive,
    required this.isDeleted,
    required this.isApproved,
    required this.createdBy,
    required this.createdUtc,
    this.modifiedBy,
    this.modifiedUtc,
    this.approvedBy,
    this.approvedUtc,
  });

  final String userGroupId;
  final String organizationId;
  final String name;
  final String? description;

  final bool isActive;
  final bool isDeleted;
  final bool isApproved;

  final String createdBy;
  final DateTime createdUtc;

  final String? modifiedBy;
  final DateTime? modifiedUtc;

  final String? approvedBy;
  final DateTime? approvedUtc;

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      userGroupId: json['userGroupId'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      isDeleted: json['isDeleted'] as bool,
      isApproved: json['isApproved'] as bool,
      createdBy: json['createdBy'] as String,
      createdUtc: DateTime.parse(json['createdUtc'] as String),
      modifiedBy: json['modifiedBy'] as String?,
      modifiedUtc: json['modifiedUtc'] == null
          ? null
          : DateTime.parse(json['modifiedUtc'] as String),
      approvedBy: json['approvedBy'] as String?,
      approvedUtc: json['approvedUtc'] == null
          ? null
          : DateTime.parse(json['approvedUtc'] as String),
    );
  }
}
