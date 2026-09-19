import 'package:flutter/material.dart';

import '../features/home/pages/home_page.dart';
import '../features/identity/pages/auth_guard.dart';
import '../features/identity/pages/login_page.dart';
import '../features/identity/pages/register_page.dart';
import '../features/identity/pages/startup_page.dart';
import '../features/landing/pages/introduction_page.dart';
import '../features/organization/pages/module_guard.dart';
import '../features/organization/pages/organization_setup_page.dart';
import '../features/service_status/pages/service_health_page.dart';
import '../shared/layouts/main_layout.dart';
import '../shared/pages/module_placeholder_page.dart';

class AppRoutes {
  static const String startup = '/';
  static const String introduction = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String home = '/home';

  static const String organization = '/organization';
  static const String users = '/users';
  static const String userGroups = '/user-groups';
  static const String roles = '/roles';
  static const String permissions = '/permissions';
  static const String licenses = '/licenses';
  static const String contacts = '/contacts';

  static const String organizationSetup = '/organization/setup';
  static const String service = '/service';

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

      case signup:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case home:
        return _protectedRoute(settings, const HomePage());

      case organization:
        return _moduleRoute(
          settings,
          moduleCode: 'ORGANIZATION',
          page: const ModulePlaceholderPage(
            title: 'Organization',
            description: 'Organization profile and settings.',
          ),
        );

      case users:
        return _moduleRoute(
          settings,
          moduleCode: 'USERS',
          page: const ModulePlaceholderPage(
            title: 'Users',
            description: 'Organization user management.',
          ),
        );

      case userGroups:
        return _moduleRoute(
          settings,
          moduleCode: 'USER_GROUPS',
          page: const ModulePlaceholderPage(
            title: 'User Groups',
            description: 'User group management.',
          ),
        );

      case roles:
        return _moduleRoute(
          settings,
          moduleCode: 'ROLES',
          page: const ModulePlaceholderPage(
            title: 'Roles',
            description: 'Role management.',
          ),
        );

      case permissions:
        return _moduleRoute(
          settings,
          moduleCode: 'PERMISSIONS',
          page: const ModulePlaceholderPage(
            title: 'Permissions',
            description: 'Permission management.',
          ),
        );

      case licenses:
        return _moduleRoute(
          settings,
          moduleCode: 'LICENSES',
          page: const ModulePlaceholderPage(
            title: 'Licenses',
            description: 'Organization license information.',
          ),
        );

      case contacts:
        return _moduleRoute(
          settings,
          moduleCode: 'CONTACT',
          page: const ModulePlaceholderPage(
            title: 'Contact',
            description: 'Contact management.',
          ),
        );

      case organizationSetup:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: OrganizationSetupPage()),
          settings: settings,
        );

      case service:
        return MaterialPageRoute(
          builder: (_) => const ServiceHealthPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const IntroductionPage(),
          settings: settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _protectedRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return MaterialPageRoute(
      builder: (_) => AuthGuard(child: MainLayout(child: page)),
      settings: settings,
    );
  }

  static MaterialPageRoute<dynamic> _moduleRoute(
    RouteSettings settings, {
    required String moduleCode,
    required Widget page,
  }) {
    return MaterialPageRoute(
      builder: (_) => AuthGuard(
        child: ModuleGuard(
          moduleCode: moduleCode,
          child: MainLayout(child: page),
        ),
      ),
      settings: settings,
    );
  }
}
