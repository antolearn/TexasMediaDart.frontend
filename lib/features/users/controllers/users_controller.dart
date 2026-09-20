import 'package:flutter/foundation.dart';

import '../models/organization_user.dart';
import '../services/users_service.dart';

class UsersController extends ChangeNotifier {
  UsersController(this._usersService);

  final UsersService _usersService;

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

  bool get hasPreviousPage => _pageNumber > 1;

  bool get hasNextPage => _pageNumber * _pageSize < _totalCount;

  Future<void> loadUsers({int pageNumber = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _usersService.searchUsers(
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );

      _users = result.items;
      _pageNumber = result.pageNumber;
      _pageSize = result.pageSize;
      _totalCount = result.totalCount;
    } catch (exception) {
      _users = [];
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (!hasNextPage || _isLoading) {
      return;
    }

    await loadUsers(pageNumber: _pageNumber + 1);
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage || _isLoading) {
      return;
    }

    await loadUsers(pageNumber: _pageNumber - 1);
  }

  Future<void> refresh() async {
    await loadUsers(pageNumber: _pageNumber);
  }
}
