import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

void main() {
  debugPrint('Environment: ${AppConfig.environment}');
  debugPrint('API Base URL: ${AppConfig.apiBaseUrl}');

  runApp(const TexasMediaDartApp());
}
