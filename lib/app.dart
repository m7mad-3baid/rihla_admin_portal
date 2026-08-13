import 'package:flutter/material.dart';

import 'screens/login_page.dart';

class RihlaAdminApp extends StatelessWidget {
  const RihlaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rihla Admin',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8F8),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
