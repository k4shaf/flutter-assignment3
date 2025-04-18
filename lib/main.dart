import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remember the Location',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationScreen(),
    );
  }
}
