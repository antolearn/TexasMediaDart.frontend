class TablePreference {
  const TablePreference({
    required this.tableKey,
    required this.pageSize,
    this.sortBy,
    required this.sortAscending,
  });

  final String tableKey;
  final int pageSize;
  final String? sortBy;
  final bool sortAscending;

  TablePreference copyWith({
    String? tableKey,
    int? pageSize,
    String? sortBy,
    bool? sortAscending,
    bool clearSortBy = false,
  }) {
    return TablePreference(
      tableKey: tableKey ?? this.tableKey,
      pageSize: pageSize ?? this.pageSize,
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableKey': tableKey,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'sortAscending': sortAscending,
    };
  }

  factory TablePreference.fromJson(Map<String, dynamic> json) {
    return TablePreference(
      tableKey: json['tableKey'] as String,
      pageSize: json['pageSize'] as int,
      sortBy: json['sortBy'] as String?,
      sortAscending: json['sortAscending'] as bool? ?? true,
    );
  }
}
