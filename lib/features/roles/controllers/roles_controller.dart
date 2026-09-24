import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/table_preferences/table_preference.dart';
import '../../../core/table_preferences/table_preference_service.dart';
import '../models/role.dart';
import '../models/role_permission.dart';
import '../services/roles_service.dart';

class RolesController extends ChangeNotifier {
  RolesController(this._rolesService, this._tablePreferenceService);

  static const String tableKey = 'ROLES';
  static const List<int> allowedPageSizes = [25, 50, 100];

  static const Set<String> allowedSortFields = {
    'name',
    'description',
    'createdUtc',
  };

  final RolesService _rolesService;
  final TablePreferenceService _tablePreferenceService;

  bool _isLoading = false;
  bool _isCreating = false;
  bool _hasSearched = false;
  bool _preferencesLoaded = false;

  String? _errorMessage;

  List<Role> _roles = [];

  // Role permissions state
  List<RolePermission> _rolePermissions = [];
  bool _isLoadingPermissions = false;
  bool _isSavingPermissions = false;
  String? _permissionsError;

  int _pageNumber = 1;
  int _pageSize = 25;
  int _totalCount = 0;

  String _search = '';
  bool? _isActive = true;
  bool _includeDeleted = false;

  String? _sortBy;
  bool _sortAscending = true;

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get hasSearched => _hasSearched;

  bool get preferencesLoaded => _preferencesLoaded;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<Role> get roles => List.unmodifiable(_roles);

  int get pageNumber => _pageNumber;

  int get pageSize => _pageSize;

  int get totalCount => _totalCount;

  String get search => _search;

  bool? get isActive => _isActive;

  bool get includeDeleted => _includeDeleted;

  String? get sortBy => _sortBy;

  bool get sortAscending => _sortAscending;

  List<RolePermission> get rolePermissions =>
      List.unmodifiable(_rolePermissions);

  bool get isLoadingPermissions => _isLoadingPermissions;

  bool get isSavingPermissions => _isSavingPermissions;

  String? get permissionsError => _permissionsError;

  bool get hasPreviousPage => _pageNumber > 1;

  bool get hasNextPage => _pageNumber < totalPages;

  int get totalPages {
    if (_totalCount == 0 || _pageSize <= 0) {
      return 0;
    }

    return (_totalCount / _pageSize).ceil();
  }

  Future<void> loadPreferences() async {
    if (_preferencesLoaded) {
      return;
    }

    try {
      final preference = await _tablePreferenceService.load(tableKey);

      if (preference != null) {
        if (allowedPageSizes.contains(preference.pageSize)) {
          _pageSize = preference.pageSize;
        }

        final savedSortBy = preference.sortBy;

        if (savedSortBy == null) {
          _sortBy = null;
          _sortAscending = true;
        } else if (allowedSortFields.contains(savedSortBy)) {
          _sortBy = savedSortBy;
          _sortAscending = preference.sortAscending;
        }
      }
    } finally {
      _preferencesLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _savePreferences() async {
    await _tablePreferenceService.save(
      TablePreference(
        tableKey: tableKey,
        pageSize: _pageSize,
        sortBy: _sortBy,
        sortAscending: _sortAscending,
      ),
    );
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
        sortBy: _sortBy,
        sortDirection: _sortBy == null
            ? null
            : (_sortAscending ? 'asc' : 'desc'),
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

    // Sorting and page size are table preferences, so Clear does not
    // reset them. Clear only resets the search/filter criteria.
    _roles = [];

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

    await _savePreferences();

    // Preserve search-first behavior.
    // Sorting before the first search must not execute the API request.
    if (!_hasSearched) {
      notifyListeners();
      return;
    }

    // Sorting changes result ordering, so restart from page 1.
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

    await _savePreferences();

    // Preserve search-first behavior.
    // Changing page size before the first search must not execute the API.
    if (!_hasSearched) {
      notifyListeners();
      return;
    }

    // Page boundaries have changed, so restart from page 1.
    await _loadPage(1);
  }

  void clearRolePermissions() {
    _rolePermissions = [];
    _permissionsError = null;
    _isLoadingPermissions = false;
    _isSavingPermissions = false;
  }

  Future<void> loadRolePermissions(String roleId) async {
    if (_isLoadingPermissions || _isSavingPermissions) {
      return;
    }

    _isLoadingPermissions = true;
    _permissionsError = null;
    _rolePermissions = [];

    notifyListeners();

    try {
      _rolePermissions = await _rolesService.getRolePermissions(roleId);
    } on ApiException catch (exception) {
      _permissionsError = exception.message;
    } catch (_) {
      _permissionsError = 'Unable to load role permissions. Please try again.';
    } finally {
      _isLoadingPermissions = false;
      notifyListeners();
    }
  }

  Future<bool> saveRolePermissions({
    required String roleId,
    required List<RolePermission> permissions,
  }) async {
    if (_isSavingPermissions || _isLoadingPermissions) {
      return false;
    }

    _isSavingPermissions = true;
    _permissionsError = null;

    notifyListeners();

    try {
      final updatedPermissions = await _rolesService.updateRolePermissions(
        roleId: roleId,
        permissions: permissions,
      );

      _rolePermissions = updatedPermissions;

      return true;
    } on ApiException catch (exception) {
      _permissionsError = exception.message;
      return false;
    } catch (_) {
      _permissionsError = 'Unable to save role permissions. Please try again.';
      return false;
    } finally {
      _isSavingPermissions = false;
      notifyListeners();
    }
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
