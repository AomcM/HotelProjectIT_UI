import 'package:flutter/material.dart';

void main() {
  runApp(const HotelITApp());
}

class HotelITApp extends StatelessWidget {
  const HotelITApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel IT Support',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel IT Support"),
      ),
      body: const Center(
        child: Text(
          "Welcome to Hotel IT Support",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}