class RolePermission {
  const RolePermission({
    required this.roleId,
    required this.moduleId,
    required this.moduleCode,
    required this.moduleName,
    required this.supportsCreate,
    required this.supportsRead,
    required this.supportsUpdate,
    required this.supportsDelete,
    required this.supportsApprove,
    required this.allowedCanCreate,
    required this.allowedCanUpdate,
    required this.allowedCanDelete,
    required this.allowedCanRead,
    required this.allowedCanApprove,
    required this.canCreate,
    required this.canUpdate,
    required this.canDelete,
    required this.canRead,
    required this.canApprove,
    this.createdBy,
    this.createdUtc,
    this.modifiedBy,
    this.modifiedUtc,
  });

  final String roleId;

  final int moduleId;
  final String moduleCode;
  final String moduleName;

  // Module capabilities
  final bool supportsCreate;
  final bool supportsRead;
  final bool supportsUpdate;
  final bool supportsDelete;
  final bool supportsApprove;

  // Maximum permissions available through the
  // organization's module entitlement.
  final bool allowedCanCreate;
  final bool allowedCanUpdate;
  final bool allowedCanDelete;
  final bool allowedCanRead;
  final bool allowedCanApprove;

  // Actual permissions assigned to the role.
  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;
  final bool canRead;
  final bool canApprove;

  // Audit
  final String? createdBy;
  final DateTime? createdUtc;

  final String? modifiedBy;
  final DateTime? modifiedUtc;

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      roleId: json['roleId'] as String,
      moduleId: json['moduleId'] as int,
      moduleCode: json['moduleCode'] as String,
      moduleName: json['moduleName'] as String,

      supportsCreate: json['supportsCreate'] as bool,
      supportsRead: json['supportsRead'] as bool,
      supportsUpdate: json['supportsUpdate'] as bool,
      supportsDelete: json['supportsDelete'] as bool,
      supportsApprove: json['supportsApprove'] as bool,

      allowedCanCreate: json['allowedCanCreate'] as bool,
      allowedCanUpdate: json['allowedCanUpdate'] as bool,
      allowedCanDelete: json['allowedCanDelete'] as bool,
      allowedCanRead: json['allowedCanRead'] as bool,
      allowedCanApprove: json['allowedCanApprove'] as bool,

      canCreate: json['canCreate'] as bool,
      canUpdate: json['canUpdate'] as bool,
      canDelete: json['canDelete'] as bool,
      canRead: json['canRead'] as bool,
      canApprove: json['canApprove'] as bool,

      createdBy: json['createdBy'] as String?,
      createdUtc: json['createdUtc'] == null
          ? null
          : DateTime.parse(json['createdUtc'] as String),

      modifiedBy: json['modifiedBy'] as String?,
      modifiedUtc: json['modifiedUtc'] == null
          ? null
          : DateTime.parse(json['modifiedUtc'] as String),
    );
  }
}
