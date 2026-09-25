import 'user_group.dart';

class UserGroupSearchResult {
  const UserGroupSearchResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<UserGroup> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  factory UserGroupSearchResult.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];

    return UserGroupSearchResult(
      items: items
          .map((item) => UserGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}
