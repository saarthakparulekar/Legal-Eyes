import 'package:flutter/material.dart';
import 'package:legal_eyes/pages/homepage.dart';
import 'package:legal_eyes/pages/landing_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}

