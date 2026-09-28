import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/organization_user.dart';
import '../models/organization_user_search_result.dart';

class UsersService {
  UsersService(this._apiClient);

  final ApiClient _apiClient;

  Future<OrganizationUserSearchResult> searchUsers({
    int pageNumber = 1,
    int pageSize = 25,
    bool? isActive,
    bool? isApproved,
    String? identityUserId,
    String? email,
    String sortBy = 'createdUtc',
    String sortDirection = 'desc',
  }) async {
    final queryParameters = <String>[
      'pageNumber=$pageNumber',
      'pageSize=$pageSize',
      'sortBy=${Uri.encodeQueryComponent(sortBy)}',
      'sortDirection=${Uri.encodeQueryComponent(sortDirection)}',
    ];

    if (isActive != null) {
      queryParameters.add('isActive=$isActive');
    }

    if (isApproved != null) {
      queryParameters.add('isApproved=$isApproved');
    }

    if (identityUserId != null && identityUserId.trim().isNotEmpty) {
      queryParameters.add(
        'identityUserId=${Uri.encodeQueryComponent(identityUserId.trim())}',
      );
    }

    if (email != null && email.trim().isNotEmpty) {
      queryParameters.add('email=${Uri.encodeQueryComponent(email.trim())}');
    }

    final response = await _apiClient.get(
      '/api/users?${queryParameters.join('&')}',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid users response.');
    }

    return OrganizationUserSearchResult.fromJson(response);
  }

  Future<OrganizationUser> addUser(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw ApiException(message: 'Email is required.');
    }

    final response = await _apiClient.post(
      '/api/users',
      authenticated: true,
      body: {'email': trimmedEmail},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid add user response.');
    }

    return OrganizationUser.fromJson(response);
  }
}
