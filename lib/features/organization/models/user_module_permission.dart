class UserModulePermission {
  const UserModulePermission({
    required this.organizationId,
    required this.organizationUserId,
    required this.moduleId,
    required this.moduleCode,
    required this.moduleName,
    this.description,
    this.route,
    this.iconKey,
    this.menuGroup,
    required this.displayOrder,
    required this.showInMenu,
    required this.canCreate,
    required this.canUpdate,
    required this.canDelete,
    required this.canRead,
  });

  final String organizationId;
  final int organizationUserId;
  final int moduleId;

  final String moduleCode;
  final String moduleName;
  final String? description;

  final String? route;
  final String? iconKey;
  final String? menuGroup;

  final int displayOrder;
  final bool showInMenu;

  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;
  final bool canRead;

  factory UserModulePermission.fromJson(Map<String, dynamic> json) {
    return UserModulePermission(
      organizationId: json['organizationId']?.toString() ?? '',
      organizationUserId: (json['organizationUserId'] as num?)?.toInt() ?? 0,
      moduleId: (json['moduleId'] as num?)?.toInt() ?? 0,
      moduleCode: json['moduleCode']?.toString() ?? '',
      moduleName: json['moduleName']?.toString() ?? '',
      description: json['description']?.toString(),
      route: json['route']?.toString(),
      iconKey: json['iconKey']?.toString(),
      menuGroup: json['menuGroup']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      showInMenu: json['showInMenu'] == true,
      canCreate: json['canCreate'] == true,
      canUpdate: json['canUpdate'] == true,
      canDelete: json['canDelete'] == true,
      canRead: json['canRead'] == true,
    );
  }
}
