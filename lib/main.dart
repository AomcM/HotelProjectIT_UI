import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'theme/app_theme.dart';
void main() {
  runApp(const HotelITApp());
}

class HotelITApp extends StatelessWidget {
  const HotelITApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        theme: AppTheme.light,

      debugShowCheckedModeBanner: false,

      title: "Hotel IT",


      home: const LoginPage(),

    );
  }
}