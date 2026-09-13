class CurrentOrganization {
  final String organizationId;
  final String name;
  final bool isActive;
  final int organizationUserId;
  final String identityUserId;
  final bool userIsActive;
  final bool userIsApproved;
  final String createdBy;
  final DateTime createdUtc;
  final String? modifiedBy;
  final DateTime? modifiedUtc;

  const CurrentOrganization({
    required this.organizationId,
    required this.name,
    required this.isActive,
    required this.organizationUserId,
    required this.identityUserId,
    required this.userIsActive,
    required this.userIsApproved,
    required this.createdBy,
    required this.createdUtc,
    this.modifiedBy,
    this.modifiedUtc,
  });

  factory CurrentOrganization.fromJson(Map<String, dynamic> json) {
    return CurrentOrganization(
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      organizationUserId: json['organizationUserId'] as int,
      identityUserId: json['identityUserId'] as String,
      userIsActive: json['userIsActive'] as bool,
      userIsApproved: json['userIsApproved'] as bool,
      createdBy: json['createdBy'] as String,
      createdUtc: DateTime.parse(json['createdUtc'] as String),
      modifiedBy: json['modifiedBy'] as String?,
      modifiedUtc: json['modifiedUtc'] == null
          ? null
          : DateTime.parse(json['modifiedUtc'] as String),
    );
  }
}
