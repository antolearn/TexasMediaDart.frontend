import 'package:flutter/material.dart';

import '../features/home/pages/home_page.dart';
import '../features/identity/pages/login_page.dart';
import '../features/landing/pages/introduction_page.dart';
import '../features/identity/pages/register_page.dart';
import '../features/identity/pages/auth_guard.dart';
import '../features/identity/pages/startup_page.dart';
import '../features/organization/pages/organization_setup_page.dart';

class AppRoutes {
  static const String startup = '/';
  static const String introduction = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String organizationSetup = '/organization/setup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case startup:
        return MaterialPageRoute(
          builder: (_) => const StartupPage(),
          settings: settings,
        );

      case introduction:
        return MaterialPageRoute(
          builder: (_) => const IntroductionPage(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: HomePage()),
          settings: settings,
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case organizationSetup:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: OrganizationSetupPage()),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const IntroductionPage(),
          settings: settings,
        );
    }
  }
}
