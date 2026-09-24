import 'role.dart';

class RoleSearchResult {
  const RoleSearchResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<Role> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  factory RoleSearchResult.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];

    return RoleSearchResult(
      items: items
          .map((item) => Role.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}
