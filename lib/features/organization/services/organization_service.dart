import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/current_organization.dart';
import '../models/user_module_permission.dart';

class OrganizationService {
  OrganizationService(this._apiClient);

  final ApiClient _apiClient;

  Future<CurrentOrganization?> getCurrentOrganization() async {
    try {
      final response = await _apiClient.get(
        '/api/organizations/current',
        authenticated: true,
      );

      if (response is! Map<String, dynamic>) {
        throw ApiException(message: 'Invalid organization response.');
      }

      return CurrentOrganization.fromJson(response);
    } on ApiException catch (exception) {
      if (exception.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  Future<CurrentOrganization> createOrganization({required String name}) async {
    final response = await _apiClient.post(
      '/api/organizations',
      authenticated: true,
      body: {'name': name.trim()},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid organization response.');
    }

    // POST returns the bootstrap result, which is not exactly the same DTO
    // as GET /current, so fetch the canonical current organization afterward.
    final organization = await getCurrentOrganization();

    if (organization == null) {
      throw ApiException(
        message: 'Organization was created but could not be loaded.',
      );
    }

    return organization;
  }

  Future<List<UserModulePermission>> getCurrentUserModules() async {
    final response = await _apiClient.get(
      '/api/organizations/current/modules',
      authenticated: true,
    );

    if (response is! List) {
      throw ApiException(message: 'Invalid organization modules response.');
    }

    return response
        .map(
          (item) => UserModulePermission.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
