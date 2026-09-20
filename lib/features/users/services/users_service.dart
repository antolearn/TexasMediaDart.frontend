import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
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
  }) async {
    final queryParameters = <String>[
      'pageNumber=$pageNumber',
      'pageSize=$pageSize',
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

    final response = await _apiClient.get(
      '/api/users?${queryParameters.join('&')}',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid users response.');
    }

    return OrganizationUserSearchResult.fromJson(response);
  }
}
