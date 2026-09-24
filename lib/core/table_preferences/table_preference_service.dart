import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'table_preference.dart';

class TablePreferenceService {
  static const String _storagePrefix = 'table_preference_';

  Future<TablePreference?> load(String tableKey) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonValue = preferences.getString(_storageKey(tableKey));

    if (jsonValue == null || jsonValue.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonValue);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return TablePreference.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(TablePreference preference) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _storageKey(preference.tableKey),
      jsonEncode(preference.toJson()),
    );
  }

  Future<void> delete(String tableKey) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey(tableKey));
  }

  String _storageKey(String tableKey) {
    return '$_storagePrefix${tableKey.trim().toUpperCase()}';
  }
}
