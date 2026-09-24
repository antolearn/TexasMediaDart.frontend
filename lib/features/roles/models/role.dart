class Role {
  const Role({
    required this.roleId,
    required this.organizationId,
    required this.name,
    this.description,
    required this.isSystemRole,
    required this.isActive,
    required this.isDeleted,
    required this.isApproved,
    required this.createdBy,
    required this.createdUtc,
    this.modifiedBy,
    this.modifiedUtc,
  });

  final String roleId;
  final String organizationId;
  final String name;
  final String? description;

  final bool isSystemRole;
  final bool isActive;
  final bool isDeleted;
  final bool isApproved;

  final String createdBy;
  final DateTime createdUtc;

  final String? modifiedBy;
  final DateTime? modifiedUtc;

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['roleId'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isSystemRole: json['isSystemRole'] as bool,
      isActive: json['isActive'] as bool,
      isDeleted: json['isDeleted'] as bool,
      isApproved: json['isApproved'] as bool,
      createdBy: json['createdBy'] as String,
      createdUtc: DateTime.parse(json['createdUtc'] as String),
      modifiedBy: json['modifiedBy'] as String?,
      modifiedUtc: json['modifiedUtc'] == null
          ? null
          : DateTime.parse(json['modifiedUtc'] as String),
    );
  }
}
