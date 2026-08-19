import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'themes/admin_theme.dart';

class RihlaAdminApp extends StatelessWidget {
  const RihlaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rihla Admin',
      theme: AdminTheme.lightTheme,
      home: const LoginPage(),
      routes: {'/login': (context) => const LoginPage()},
    );
  }
}
