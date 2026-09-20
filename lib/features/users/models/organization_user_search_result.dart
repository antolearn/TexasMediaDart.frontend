import 'organization_user.dart';

class OrganizationUserSearchResult {
  const OrganizationUserSearchResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<OrganizationUser> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  factory OrganizationUserSearchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return OrganizationUserSearchResult(
      items: rawItems is List
          ? rawItems
                .map(
                  (item) =>
                      OrganizationUser.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : <OrganizationUser>[],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 25,
    );
  }
}
