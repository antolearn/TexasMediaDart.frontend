import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/current_organization.dart';

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
}
