import 'user_group_member.dart';

class UserGroupMemberSearchResult {
  const UserGroupMemberSearchResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<UserGroupMember> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  factory UserGroupMemberSearchResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return UserGroupMemberSearchResult(
      items: rawItems is List
          ? rawItems
                .map(
                  (item) =>
                      UserGroupMember.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : <UserGroupMember>[],
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 25,
    );
  }
}
