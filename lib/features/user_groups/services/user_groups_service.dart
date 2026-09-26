import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/user_group_search_result.dart';
import '../models/user_group.dart';
import '../models/user_group_member_search_result.dart';

class UserGroupsService {
  UserGroupsService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserGroupSearchResult> searchUserGroups({
    String? searchText,
    bool? isActive,
    bool? isApproved,
    bool includeDeleted = false,
    String? sortBy,
    String? sortDirection,
    int pageNumber = 1,
    int pageSize = 25,
  }) async {
    final queryParameters = <String>[
      'pageNumber=$pageNumber',
      'pageSize=$pageSize',
      'includeDeleted=$includeDeleted',
    ];

    if (searchText != null && searchText.trim().isNotEmpty) {
      queryParameters.add(
        'searchText=${Uri.encodeQueryComponent(searchText.trim())}',
      );
    }

    if (isActive != null) {
      queryParameters.add('isActive=$isActive');
    }

    if (isApproved != null) {
      queryParameters.add('isApproved=$isApproved');
    }

    if (sortBy != null && sortBy.trim().isNotEmpty) {
      queryParameters.add('sortBy=${Uri.encodeQueryComponent(sortBy.trim())}');
    }

    if (sortDirection != null && sortDirection.trim().isNotEmpty) {
      queryParameters.add(
        'sortDirection=${Uri.encodeQueryComponent(sortDirection.trim())}',
      );
    }
    final response = await _apiClient.get(
      '/api/user-groups?${queryParameters.join('&')}',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid user groups response.');
    }

    return UserGroupSearchResult.fromJson(response);
  }

  Future<UserGroup> createUserGroup({
    required String name,
    String? description,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    final response = await _apiClient.post(
      '/api/user-groups',
      body: {
        'name': trimmedName,
        'description': trimmedDescription == null || trimmedDescription.isEmpty
            ? null
            : trimmedDescription,
      },
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid create user group response.');
    }

    return UserGroup.fromJson(response);
  }

  Future<UserGroup> updateUserGroup({
    required String userGroupId,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    final response = await _apiClient.put(
      '/api/user-groups/$userGroupId',
      body: {
        'name': trimmedName,
        'description': trimmedDescription == null || trimmedDescription.isEmpty
            ? null
            : trimmedDescription,
        'isActive': isActive,
      },
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid update user group response.');
    }

    return UserGroup.fromJson(response);
  }

  Future<UserGroup> deleteUserGroup({required String userGroupId}) async {
    final response = await _apiClient.delete(
      '/api/user-groups/$userGroupId',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid delete user group response.');
    }

    return UserGroup.fromJson(response);
  }

  Future<UserGroupMemberSearchResult> searchMembers({
    required String userGroupId,
    bool? isActive,
    bool? isApproved,
    int pageNumber = 1,
    int pageSize = 25,
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

    final response = await _apiClient.get(
      '/api/user-groups/$userGroupId/members'
      '?${queryParameters.join('&')}',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid user group members response.');
    }

    return UserGroupMemberSearchResult.fromJson(response);
  }

  Future<void> addMember({
    required String userGroupId,
    required int organizationUserId,
  }) async {
    await _apiClient.post(
      '/api/user-groups/$userGroupId/members',
      body: {'organizationUserId': organizationUserId},
      authenticated: true,
    );
  }

  Future<void> removeMember({
    required String userGroupId,
    required int organizationUserId,
  }) async {
    await _apiClient.delete(
      '/api/user-groups/$userGroupId/members/$organizationUserId',
      authenticated: true,
    );
  }
}
