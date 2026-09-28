import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class UserInvitationService {
  UserInvitationService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedToken = token.trim();

    if (trimmedToken.isEmpty) {
      throw ApiException(message: 'Invitation token is required.');
    }

    await _apiClient.post(
      '/api/user-invitations/accept',
      authenticated: false,
      body: {
        'token': trimmedToken,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }
}
