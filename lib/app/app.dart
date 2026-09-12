import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/identity_api_client.dart';
import '../core/network/main_api_client.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/home/services/health_service.dart';
import '../features/identity/services/auth_service.dart';
import '../features/identity/services/session_manager.dart';
import '../features/identity/services/current_user_service.dart';

import 'routes.dart';

class TexasMediaDartApp extends StatelessWidget {
  const TexasMediaDartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SessionManager>(create: (_) => SessionManager()),

        Provider<AuthService>(
          create: (context) =>
              AuthService(sessionManager: context.read<SessionManager>()),
          dispose: (_, authService) => authService.dispose(),
        ),

        Provider<MainApiClient>(
          create: (context) {
            final sessionManager = context.read<SessionManager>();
            final authService = context.read<AuthService>();

            final client = ApiClient(
              baseUrl: AppConfig.apiBaseUrl,
              accessTokenProvider: sessionManager.getAccessToken,
              accessTokenRefresher: () async {
                final tokens = await authService.refreshSession();
                return tokens.accessToken;
              },
            );

            return MainApiClient(client);
          },
          dispose: (_, mainApiClient) => mainApiClient.client.dispose(),
        ),

        Provider<IdentityApiClient>(
          create: (context) {
            final sessionManager = context.read<SessionManager>();
            final authService = context.read<AuthService>();

            final client = ApiClient(
              baseUrl: AppConfig.identityApiBaseUrl,
              accessTokenProvider: sessionManager.getAccessToken,
              accessTokenRefresher: () async {
                final tokens = await authService.refreshSession();
                return tokens.accessToken;
              },
            );

            return IdentityApiClient(client);
          },
          dispose: (_, identityApiClient) => identityApiClient.client.dispose(),
        ),

        Provider<CurrentUserService>(
          create: (context) => CurrentUserService(
            apiClient: context.read<IdentityApiClient>().client,
          ),
        ),

        Provider<HealthService>(
          create: (context) =>
              HealthService(apiClient: context.read<MainApiClient>().client),
        ),

        ChangeNotifierProvider<HomeController>(
          create: (context) =>
              HomeController(healthService: context.read<HealthService>())
                ..loadHealthStatus(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TexasMediaDart',
        initialRoute: AppRoutes.startup,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
