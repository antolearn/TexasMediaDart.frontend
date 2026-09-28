import 'package:flutter/foundation.dart';

import '../models/organization_user.dart';
import '../services/users_service.dart';

class UsersController extends ChangeNotifier {
  UsersController(this._usersService);

  static const List<int> allowedPageSizes = [25, 50, 100];

  final UsersService _usersService;

  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isAddingUser = false;

  String? _errorMessage;

  List<OrganizationUser> _users = [];

  int _pageNumber = 1;
  int _pageSize = 25;
  int _totalCount = 0;

  String? _email;
  bool? _isActive = true;
  bool? _isApproved;

  String _sortBy = 'createdUtc';
  bool _sortAscending = false;

  bool get isLoading => _isLoading;
  bool get isAddingUser => _isAddingUser;

  bool get hasSearched => _hasSearched;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<OrganizationUser> get users => List.unmodifiable(_users);

  int get pageNumber => _pageNumber;

  int get pageSize => _pageSize;

  int get totalCount => _totalCount;

  String? get email => _email;

  bool? get isActive => _isActive;

  bool? get isApproved => _isApproved;

  String get sortBy => _sortBy;

  bool get sortAscending => _sortAscending;

  bool get hasPreviousPage => _pageNumber > 1;

  bool get hasNextPage => _pageNumber < totalPages;

  int get totalPages {
    if (_totalCount == 0 || _pageSize <= 0) {
      return 0;
    }

    return (_totalCount / _pageSize).ceil();
  }

  Future<void> applyFilters({
    String? email,
    required bool? isActive,
    required bool? isApproved,
  }) async {
    final trimmedEmail = email?.trim();

    _email = trimmedEmail == null || trimmedEmail.isEmpty ? null : trimmedEmail;

    _isActive = isActive;
    _isApproved = isApproved;

    await _loadPage(1);
  }

  Future<void> _loadPage(int pageNumber) async {
    _isLoading = true;
    _hasSearched = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _usersService.searchUsers(
        pageNumber: pageNumber,
        pageSize: _pageSize,
        email: _email,
        isActive: _isActive,
        isApproved: _isApproved,
        sortBy: _sortBy,
        sortDirection: _sortAscending ? 'asc' : 'desc',
      );

      _users = result.items;
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

  void clearFilters() {
    _email = null;
    _isActive = true;
    _isApproved = null;

    _users = [];
    _pageNumber = 1;
    _totalCount = 0;

    _errorMessage = null;
    _hasSearched = false;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> sortByCreatedUtc(bool ascending) async {
    if (_isLoading) {
      return;
    }

    _sortBy = 'createdUtc';
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

  Future<OrganizationUser> addUser(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    if (_isAddingUser) {
      throw StateError('A user is already being added.');
    }

    _isAddingUser = true;
    notifyListeners();

    try {
      final user = await _usersService.addUser(trimmedEmail);

      if (_hasSearched) {
        await _loadPage(1);
      }

      return user;
    } finally {
      _isAddingUser = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!_hasSearched || _isLoading) {
      return;
    }

    await _loadPage(_pageNumber);
  }
}
