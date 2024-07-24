import 'dart:io';

import 'package:bike_project/response/homepage.dart';
import 'package:bike_project/screens/home.dart';
import 'package:bike_project/screens/otp.dart';
import 'package:bike_project/screens/response.dart';
import 'package:bike_project/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bike_project/screens/phone.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login.dart';
import 'screens/otpold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD0sPQwYjN7cAh8QlMoNmkPLESupfXXgG8",
        appId: "1:216528158205:android:222ecb5ab66986f403ad94",
        messagingSenderId: "216528158205",
        projectId: "bike-db1c2",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splashscreen',
      routes: {
        'splashscreen': (context) => const AnimatedSVGDemo(),
        'phone': (context) => const MyPhone(),
        'otpold': (context) => const Myotp(),
        'otp': (context) => OtpVerificationPage(),
        'response': (context) => ResponsePage(),
        'MyHome': (context) => MyHome(),
      },
    );
  }

  Future<String?> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionId');
  }
}
