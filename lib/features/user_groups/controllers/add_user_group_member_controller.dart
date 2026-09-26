import 'package:flutter/foundation.dart';

import '../../users/models/organization_user.dart';
import '../../users/services/users_service.dart';
import '../models/user_group_member.dart';

class AddUserGroupMemberController extends ChangeNotifier {
  AddUserGroupMemberController(
    this._usersService, {
    required List<UserGroupMember> existingMembers,
  }) : _existingOrganizationUserIds = existingMembers
           .map((member) => member.organizationUserId)
           .toSet();

  static const List<int> allowedPageSizes = [25, 50, 100];

  final UsersService _usersService;
  final Set<int> _existingOrganizationUserIds;

  bool _isLoading = false;
  String? _errorMessage;

  List<OrganizationUser> _users = [];

  int _pageNumber = 1;
  int _pageSize = 25;
  int _totalCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  List<OrganizationUser> get users => List.unmodifiable(_users);

  int get pageNumber => _pageNumber;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;

  int get totalPages {
    if (_totalCount == 0 || _pageSize <= 0) {
      return 0;
    }

    return (_totalCount / _pageSize).ceil();
  }

  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < totalPages;

  Future<void> loadUsers({int pageNumber = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _usersService.searchUsers(
        pageNumber: pageNumber,
        pageSize: _pageSize,
        isActive: true,
        isApproved: true,
      );

      _users = result.items
          .where(
            (user) =>
                !_existingOrganizationUserIds.contains(
                  user.organizationUserId,
                ) &&
                user.identityIsActive,
          )
          .toList();

      _pageNumber = result.pageNumber;
      _pageSize = result.pageSize;
      _totalCount = result.totalCount;
    } catch (exception) {
      _users = [];
      _pageNumber = 1;
      _totalCount = 0;
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
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
    await loadUsers(pageNumber: 1);
  }

  Future<void> firstPage() async {
    if (!hasPreviousPage || _isLoading) {
      return;
    }

    await loadUsers(pageNumber: 1);
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage || _isLoading) {
      return;
    }

    await loadUsers(pageNumber: _pageNumber - 1);
  }

  Future<void> nextPage() async {
    if (!hasNextPage || _isLoading) {
      return;
    }

    await loadUsers(pageNumber: _pageNumber + 1);
  }

  Future<void> lastPage() async {
    if (!hasNextPage || _isLoading) {
      return;
    }

    final lastPageNumber = totalPages;

    if (lastPageNumber <= 0) {
      return;
    }

    await loadUsers(pageNumber: lastPageNumber);
  }

  Future<void> refresh() async {
    if (_isLoading) {
      return;
    }

    await loadUsers(pageNumber: _pageNumber);
  }
}
