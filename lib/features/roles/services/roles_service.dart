import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/role.dart';
import '../models/role_search_result.dart';

class RolesService {
  RolesService(this._apiClient);

  final ApiClient _apiClient;

  Future<RoleSearchResult> searchRoles({
    String? search,
    bool? isActive,
    bool includeDeleted = false,
    int pageNumber = 1,
    int pageSize = 25,
  }) async {
    final queryParameters = <String>[
      'pageNumber=$pageNumber',
      'pageSize=$pageSize',
      'includeDeleted=$includeDeleted',
    ];

    if (search != null && search.trim().isNotEmpty) {
      queryParameters.add(
        'searchText=${Uri.encodeQueryComponent(search.trim())}',
      );
    }

    if (isActive != null) {
      queryParameters.add('isActive=$isActive');
    }

    final response = await _apiClient.get(
      '/api/roles?${queryParameters.join('&')}',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid roles response.');
    }

    return RoleSearchResult.fromJson(response);
  }

  Future<Role> createRole({required String name, String? description}) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    final response = await _apiClient.post(
      '/api/roles',
      body: {
        'name': trimmedName,
        'description': trimmedDescription == null || trimmedDescription.isEmpty
            ? null
            : trimmedDescription,
      },
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid create role response.');
    }

    return Role.fromJson(response);
  }

  Future<Role> updateRole({
    required String roleId,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    final response = await _apiClient.put(
      '/api/roles/$roleId',
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
      throw ApiException(message: 'Invalid update role response.');
    }

    return Role.fromJson(response);
  }

  Future<Role> deleteRole({required String roleId}) async {
    final response = await _apiClient.delete(
      '/api/roles/$roleId',
      authenticated: true,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid delete role response.');
    }

    return Role.fromJson(response);
  }
}
