import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khmerify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003DA5),
        ),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
    );
  }
}