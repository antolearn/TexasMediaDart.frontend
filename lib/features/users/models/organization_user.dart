class OrganizationUser {
  const OrganizationUser({
    required this.organizationUserId,
    required this.organizationId,
    required this.identityUserId,
    required this.email,
    required this.isActive,
    required this.isApproved,
    required this.identityIsActive,
    required this.isEmailVerified,
    required this.createdBy,
    required this.createdUtc,
    this.modifiedBy,
    this.modifiedUtc,
    this.approvedBy,
    this.approvedUtc,
  });

  final int organizationUserId;
  final String organizationId;
  final String identityUserId;

  final String? email;

  // Organization membership status
  final bool isActive;
  final bool isApproved;

  // Identity account status
  final bool identityIsActive;
  final bool isEmailVerified;

  final String createdBy;
  final DateTime createdUtc;

  final String? modifiedBy;
  final DateTime? modifiedUtc;

  final String? approvedBy;
  final DateTime? approvedUtc;

  factory OrganizationUser.fromJson(Map<String, dynamic> json) {
    return OrganizationUser(
      organizationUserId: (json['organizationUserId'] as num?)?.toInt() ?? 0,
      organizationId: json['organizationId']?.toString() ?? '',
      identityUserId: json['identityUserId']?.toString() ?? '',
      email: json['email']?.toString(),
      isActive: json['isActive'] == true,
      isApproved: json['isApproved'] == true,
      identityIsActive: json['identityIsActive'] == true,
      isEmailVerified: json['isEmailVerified'] == true,
      createdBy: json['createdBy']?.toString() ?? '',
      createdUtc: DateTime.parse(json['createdUtc'].toString()),
      modifiedBy: json['modifiedBy']?.toString(),
      modifiedUtc: _parseDateTime(json['modifiedUtc']),
      approvedBy: json['approvedBy']?.toString(),
      approvedUtc: _parseDateTime(json['approvedUtc']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}
