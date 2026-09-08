import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/home/controllers/home_controller.dart';
import '../features/home/pages/home_page.dart';

class TexasMediaDartApp extends StatelessWidget {
  const TexasMediaDartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeController()..loadHealthStatus(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TexasMediaDart',
        home: const HomePage(),
      ),
    );
  }
}
