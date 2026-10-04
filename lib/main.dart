import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //
  // Use normal browser paths instead of hash-based URLs.
  //
  // Before:
  //   /#/login
  //   /#/accept-invitation?token=...
  //
  // After:
  //   /login
  //   /accept-invitation?token=...
  //
  usePathUrlStrategy();

  await AppConfig.initialize();

  runApp(const TexasMediaDartApp());
}
