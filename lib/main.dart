import 'package:flutter/material.dart';
import 'package:jal_studio/screens/splash_screen.dart';

void main() {
  runApp(const JalStudio());
}

class JalStudio extends StatelessWidget {
  const JalStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jal Studio',
      home: SplashScreen(),
    );
  }
}