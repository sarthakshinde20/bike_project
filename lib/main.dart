import 'dart:io';
import 'package:bike_project/screens/home.dart';
import 'package:bike_project/screens/otp.dart';
import 'package:bike_project/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splashscreen',
      routes: {
        'splashscreen': (context) => const AnimatedVideoDemo(),
        'login': (context) => LoginPage(),
        'otp': (context) => OtpVerificationPage(),
        'MyHome': (context) => MyHome(),
      },
    );
  }
}
