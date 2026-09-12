import '../../../core/network/api_client.dart';
import '../models/user_profile.dart';

class CurrentUserService {
  CurrentUserService({required this._apiClient});

  final ApiClient _apiClient;

  Future<UserProfile> getCurrentUser() async {
    final response = await _apiClient.get('/api/auth/me', authenticated: true);

    if (response is! Map<String, dynamic>) {
      throw Exception('Unexpected response format from /api/auth/me');
    }

    return UserProfile.fromJson(response);
  }
}
