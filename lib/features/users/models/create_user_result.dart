import 'organization_user.dart';
import 'user_invitation.dart';

class CreateUserResult {
  const CreateUserResult({required this.status, this.user, this.invitation});

  final String status;
  final OrganizationUser? user;
  final UserInvitation? invitation;

  bool get wasAdded => status == 'added';

  bool get wasInvited => status == 'invited';

  factory CreateUserResult.fromJson(Map<String, dynamic> json) {
    return CreateUserResult(
      status: json['status'] as String? ?? '',
      user: json['user'] is Map<String, dynamic>
          ? OrganizationUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      invitation: json['invitation'] is Map<String, dynamic>
          ? UserInvitation.fromJson(json['invitation'] as Map<String, dynamic>)
          : null,
    );
  }
}
