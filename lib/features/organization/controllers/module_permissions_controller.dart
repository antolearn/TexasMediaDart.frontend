import 'package:flutter/foundation.dart';

import '../models/user_module_permission.dart';
import '../services/organization_service.dart';

class ModulePermissionsController extends ChangeNotifier {
  ModulePermissionsController(this._organizationService);

  final OrganizationService _organizationService;

  bool _isLoading = false;
  bool _isLoaded = false;
  String? _errorMessage;
  List<UserModulePermission> _modules = [];

  bool get isLoading => _isLoading;

  bool get isLoaded => _isLoaded;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  List<UserModulePermission> get modules => List.unmodifiable(_modules);

  Future<void> loadModules({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    if (_isLoaded && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final modules = await _organizationService.getCurrentUserModules();

      modules.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      _modules = modules;
      _isLoaded = true;

      debugPrint('Loaded ${_modules.length} modules:');

      for (final module in _modules) {
        debugPrint(
          '${module.moduleCode} | '
          '${module.moduleName} | '
          '${module.route} | '
          '${module.menuGroup} | '
          'Read=${module.canRead}',
        );
      }
    } catch (exception) {
      _modules = [];
      _isLoaded = false;
      _errorMessage = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshModules() async {
    await loadModules(forceRefresh: true);
  }

  bool canRead(String moduleCode) {
    return _findModule(moduleCode)?.canRead ?? false;
  }

  bool canCreate(String moduleCode) {
    return _findModule(moduleCode)?.canCreate ?? false;
  }

  bool canUpdate(String moduleCode) {
    return _findModule(moduleCode)?.canUpdate ?? false;
  }

  bool canDelete(String moduleCode) {
    return _findModule(moduleCode)?.canDelete ?? false;
  }

  bool canAccessRoute(String route) {
    for (final module in _modules) {
      if (module.route == route) {
        return module.canRead;
      }
    }

    return false;
  }

  UserModulePermission? getModule(String moduleCode) {
    return _findModule(moduleCode);
  }

  void clear() {
    _modules = [];
    _isLoaded = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  UserModulePermission? _findModule(String moduleCode) {
    for (final module in _modules) {
      if (module.moduleCode.toUpperCase() == moduleCode.toUpperCase()) {
        return module;
      }
    }

    return null;
  }
}
