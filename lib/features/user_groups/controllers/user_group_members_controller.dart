import 'package:flutter/foundation.dart';

import '../models/user_group_member.dart';
import '../services/user_groups_service.dart';

class UserGroupMembersController extends ChangeNotifier {
  UserGroupMembersController(this._userGroupsService);

  static const List<int> allowedPageSizes = [25, 50, 100];

  final UserGroupsService _userGroupsService;

  bool _isLoading = false;
  bool _isAdding = false;
  bool _isRemoving = false;

  String? _errorMessage;
  String? _userGroupId;

  List<UserGroupMember> _members = [];

  int _pageNumber = 1;
  int _pageSize = 25;
  int _totalCount = 0;

  bool? _isActive;
  bool? _isApproved;

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  bool get isRemoving => _isRemoving;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  String? get userGroupId => _userGroupId;

  List<UserGroupMember> get members => List.unmodifiable(_members);

  int get pageNumber => _pageNumber;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;

  bool? get isActive => _isActive;
  bool? get isApproved => _isApproved;

  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < totalPages;

  int get totalPages {
    if (_totalCount == 0 || _pageSize <= 0) {
      return 0;
    }

    return (_totalCount / _pageSize).ceil();
  }

  Future<void> loadMembers({
    required String userGroupId,
    int pageNumber = 1,
  }) async {
    _userGroupId = userGroupId;
    await _loadPage(pageNumber);
  }

  Future<void> _loadPage(int pageNumber) async {
    final groupId = _userGroupId;

    if (groupId == null || groupId.isEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _userGroupsService.searchMembers(
        userGroupId: groupId,
        isActive: _isActive,
        isApproved: _isApproved,
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );

      _members = result.items;
      _pageNumber = result.pageNumber;
      _pageSize = result.pageSize;
      _totalCount = result.totalCount;
    } catch (exception) {
      _members = [];
      _pageNumber = 1;
      _totalCount = 0;
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    required bool? isActive,
    required bool? isApproved,
  }) async {
    _isActive = isActive;
    _isApproved = isApproved;

    await _loadPage(1);
  }

  Future<void> addMember({required int organizationUserId}) async {
    final groupId = _userGroupId;

    if (groupId == null || groupId.isEmpty) {
      return;
    }

    _isAdding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userGroupsService.addMember(
        userGroupId: groupId,
        organizationUserId: organizationUserId,
      );

      await _loadPage(1);
    } catch (exception) {
      _errorMessage = exception.toString();
      rethrow;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  Future<void> removeMember({required int organizationUserId}) async {
    final groupId = _userGroupId;

    if (groupId == null || groupId.isEmpty) {
      return;
    }

    _isRemoving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userGroupsService.removeMember(
        userGroupId: groupId,
        organizationUserId: organizationUserId,
      );

      var pageToLoad = _pageNumber;

      if (_members.length == 1 && pageToLoad > 1) {
        pageToLoad--;
      }

      await _loadPage(pageToLoad);
    } catch (exception) {
      _errorMessage = exception.toString();
      rethrow;
    } finally {
      _isRemoving = false;
      notifyListeners();
    }
  }

  Future<void> changePageSize(int pageSize) async {
    if (!allowedPageSizes.contains(pageSize)) {
      return;
    }

    if (_pageSize == pageSize || _isLoading) {
      return;
    }

    _pageSize = pageSize;
    await _loadPage(1);
  }

  Future<void> firstPage() async {
    if (!hasPreviousPage || _isLoading) {
      return;
    }

    await _loadPage(1);
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage || _isLoading) {
      return;
    }

    await _loadPage(_pageNumber - 1);
  }

  Future<void> nextPage() async {
    if (!hasNextPage || _isLoading) {
      return;
    }

    await _loadPage(_pageNumber + 1);
  }

  Future<void> lastPage() async {
    if (!hasNextPage || _isLoading) {
      return;
    }

    final lastPageNumber = totalPages;

    if (lastPageNumber <= 0) {
      return;
    }

    await _loadPage(lastPageNumber);
  }

  Future<void> refresh() async {
    if (_isLoading) {
      return;
    }

    await _loadPage(_pageNumber);
  }

  void clear() {
    _userGroupId = null;
    _members = [];

    _pageNumber = 1;
    _pageSize = 25;
    _totalCount = 0;

    _isActive = null;
    _isApproved = null;

    _errorMessage = null;
    _isLoading = false;
    _isAdding = false;
    _isRemoving = false;

    notifyListeners();
  }
}
