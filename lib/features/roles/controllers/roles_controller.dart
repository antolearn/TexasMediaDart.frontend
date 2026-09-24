import 'package:flutter/foundation.dart';

import '../models/role.dart';
import '../services/roles_service.dart';

class RolesController extends ChangeNotifier {
  RolesController(this._rolesService);

  final RolesService _rolesService;

  bool _isLoading = false;
  bool _isCreating = false;
  bool _hasSearched = false;

  String? _errorMessage;

  List<Role> _roles = [];

  int _pageNumber = 1;
  int _pageSize = 25;
  int _totalCount = 0;

  String _search = '';
  bool? _isActive = true;
  bool _includeDeleted = false;

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get hasSearched => _hasSearched;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<Role> get roles => List.unmodifiable(_roles);

  int get pageNumber => _pageNumber;

  int get pageSize => _pageSize;

  int get totalCount => _totalCount;

  String get search => _search;

  bool? get isActive => _isActive;

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
    required String search,
    required bool? isActive,
    required bool includeDeleted,
  }) async {
    _search = search.trim();
    _isActive = isActive;
    _includeDeleted = includeDeleted;

    await _loadPage(1);
  }

  Future<void> _loadPage(int pageNumber) async {
    _isLoading = true;
    _hasSearched = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _rolesService.searchRoles(
        search: _search,
        isActive: _isActive,
        includeDeleted: _includeDeleted,
        pageNumber: pageNumber,
        pageSize: _pageSize,
      );

      _roles = result.items;
      _pageNumber = result.pageNumber;
      _pageSize = result.pageSize;
      _totalCount = result.totalCount;
    } catch (exception) {
      _roles = [];
      _pageNumber = 1;
      _totalCount = 0;
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Role> createRole({required String name, String? description}) async {
    _isCreating = true;
    notifyListeners();

    try {
      final role = await _rolesService.createRole(
        name: name,
        description: description,
      );

      return role;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<Role> updateRole({
    required String roleId,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    _isCreating = true;
    notifyListeners();

    try {
      final role = await _rolesService.updateRole(
        roleId: roleId,
        name: name,
        description: description,
        isActive: isActive,
      );

      return role;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<Role> deleteRole({required String roleId}) async {
    _isCreating = true;
    notifyListeners();

    try {
      final role = await _rolesService.deleteRole(roleId: roleId);

      return role;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> refreshAfterCreate() async {
    if (!_hasSearched) {
      return;
    }

    await _loadPage(1);
  }

  void clearFilters() {
    _search = '';
    _isActive = true;
    _includeDeleted = false;

    _roles = [];

    _pageNumber = 1;
    _totalCount = 0;

    _errorMessage = null;
    _hasSearched = false;
    _isLoading = false;

    notifyListeners();
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
