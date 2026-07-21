import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const HotelITApp());
}

class HotelITApp extends StatelessWidget {
  const HotelITApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Hoatel IT",

      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),

      home: const HomePage(),

    );
  }
}