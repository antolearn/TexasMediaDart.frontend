import 'package:flutter/foundation.dart';

import '../models/user_group.dart';
import '../services/user_groups_service.dart';

class UserGroupsController extends ChangeNotifier {
  UserGroupsController(this._userGroupsService);

  static const List<int> allowedPageSizes = [25, 50, 100];
  static const Set<String> allowedSortFields = {
    'name',
    'description',
    'createdUtc',
  };

  final UserGroupsService _userGroupsService;

  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  String? _errorMessage;
  List<UserGroup> _userGroups = [];

  int _pageNumber = 1;
  int _pageSize = 25;
  int _totalCount = 0;

  String _searchText = '';
  bool? _isActive = true;
  bool? _isApproved;
  bool _includeDeleted = false;
  String? _sortBy;
  bool _sortAscending = true;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  List<UserGroup> get userGroups => List.unmodifiable(_userGroups);

  int get pageNumber => _pageNumber;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;

  String get searchText => _searchText;
  bool? get isActive => _isActive;
  bool? get isApproved => _isApproved;
  bool get includeDeleted => _includeDeleted;

  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < totalPages;

  int get totalPages {
    if (_totalCount == 0 || _pageSize <= 0) {
      return 0;
    }

    return (_totalCount / _pageSize).ceil();
  }

  Future<void> applyFilters({
    required String searchText,
    required bool? isActive,
    required bool? isApproved,
    required bool includeDeleted,
  }) async {
    _searchText = searchText.trim();
    _isActive = isActive;
    _isApproved = isApproved;
    _includeDeleted = includeDeleted;

    await _loadPage(1);
  }

  Future<void> _loadPage(int pageNumber) async {
    _isLoading = true;
    _hasSearched = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _userGroupsService.searchUserGroups(
        searchText: _searchText,
        isActive: _isActive,
        isApproved: _isApproved,
        includeDeleted: _includeDeleted,
        sortBy: _sortBy,
        sortDirection: _sortBy == null
            ? null
            : (_sortAscending ? 'asc' : 'desc'),
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );

      _userGroups = result.items;
      _pageNumber = result.pageNumber;
      _pageSize = result.pageSize;
      _totalCount = result.totalCount;
    } catch (exception) {
      _userGroups = [];
      _pageNumber = 1;
      _totalCount = 0;
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserGroup> createUserGroup({
    required String name,
    String? description,
  }) async {
    _isCreating = true;
    notifyListeners();

    try {
      return await _userGroupsService.createUserGroup(
        name: name,
        description: description,
      );
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<UserGroup> updateUserGroup({
    required String userGroupId,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    _isUpdating = true;
    notifyListeners();

    try {
      return await _userGroupsService.updateUserGroup(
        userGroupId: userGroupId,
        name: name,
        description: description,
        isActive: isActive,
      );
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<UserGroup> deleteUserGroup({required String userGroupId}) async {
    _isDeleting = true;
    notifyListeners();

    try {
      return await _userGroupsService.deleteUserGroup(userGroupId: userGroupId);
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> refreshAfterCreate() async {
    if (!_hasSearched) {
      return;
    }

    await _loadPage(1);
  }

  Future<void> refreshAfterUpdate() async {
    if (!_hasSearched) {
      return;
    }

    await _loadPage(_pageNumber);
  }

  Future<void> refreshAfterDelete() async {
    if (!_hasSearched) {
      return;
    }

    var pageToLoad = _pageNumber;

    if (_userGroups.length == 1 && pageToLoad > 1) {
      pageToLoad--;
    }

    await _loadPage(pageToLoad);
  }

  void clearFilters() {
    _searchText = '';
    _isActive = true;
    _isApproved = null;
    _includeDeleted = false;

    _userGroups = [];

    _pageNumber = 1;
    _totalCount = 0;

    _errorMessage = null;
    _hasSearched = false;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> sortByColumn(String sortBy, bool ascending) async {
    if (_isLoading) {
      return;
    }

    if (!allowedSortFields.contains(sortBy)) {
      return;
    }

    _sortBy = sortBy;
    _sortAscending = ascending;

    if (!_hasSearched) {
      notifyListeners();
      return;
    }

    await _loadPage(1);
  }

  Future<void> changePageSize(int pageSize) async {
    if (!allowedPageSizes.contains(pageSize)) {
      return;
    }

    if (_pageSize == pageSize || _isLoading) {
      return;
    }

    _pageSize = pageSize;

    if (!_hasSearched) {
      notifyListeners();
      return;
    }

    await _loadPage(1);
  }

  Future<void> firstPage() async {
    if (!hasPreviousPage || _isLoading || !_hasSearched) {
      return;
    }

    await _loadPage(1);
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage || _isLoading || !_hasSearched) {
      return;
    }

    await _loadPage(_pageNumber - 1);
  }

  Future<void> nextPage() async {
    if (!hasNextPage || _isLoading || !_hasSearched) {
      return;
    }

    await _loadPage(_pageNumber + 1);
  }

  Future<void> lastPage() async {
    if (!hasNextPage || _isLoading || !_hasSearched) {
      return;
    }

    final lastPageNumber = totalPages;

    if (lastPageNumber <= 0) {
      return;
    }

    await _loadPage(lastPageNumber);
  }

  Future<void> refresh() async {
    if (!_hasSearched || _isLoading) {
      return;
    }

    await _loadPage(_pageNumber);
  }
}
