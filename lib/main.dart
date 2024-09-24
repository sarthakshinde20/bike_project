import 'dart:convert';
import 'dart:io'; // Import to check platform
import 'package:bike_project/screens/home.dart';
import 'package:bike_project/screens/notification.dart';
import 'package:bike_project/screens/otp.dart';
import 'package:bike_project/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDY28yUcoyaT6_TYbS8xwwVZBpU79_rHFc", // API key
        appId: "1:936541521610:android:1c59831f7882085f3a5633", // App ID
        messagingSenderId: "936541521610", // Messaging sender ID
        projectId: "briskev", // Project ID
        storageBucket: "briskev.appspot.com", // Storage bucket
      ),
    );
  } else {
    // For iOS or any other platform
    await Firebase.initializeApp();
  }

  final prefs = await SharedPreferences.getInstance();
  final sessionId = prefs.getString('sessionId') ?? '';
  final vehicleId = prefs.getString('vehicleId') ?? '';
  final name = prefs.getString('name') ?? '';

  final dashboardDataString = prefs.getString('dashboardData');
  final responseDataString = prefs.getString('responseData');

  final dashboardData = dashboardDataString != null
      ? Map<String, dynamic>.from(await json.decode(dashboardDataString))
      : null;
  final responseData = responseDataString != null
      ? Map<String, dynamic>.from(await json.decode(responseDataString))
      : null;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp(
      sessionId: sessionId,
      vehicleId: vehicleId,
      name: name,
      dashboardData: dashboardData,
      responseData: responseData,
    ));
  });
}

class MyApp extends StatelessWidget {
  final String sessionId;
  final String vehicleId;
  final String name;
  final Map<String, dynamic>? dashboardData;
  final Map<String, dynamic>? responseData;

  const MyApp({
    Key? key,
    required this.sessionId,
    required this.vehicleId,
    required this.name,
    this.dashboardData,
    this.responseData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splashscreen',
      routes: {
        'splashscreen': (context) => const AnimatedVideoDemo(),
        'login': (context) => const LoginPage(),
        'otp': (context) => const OtpVerificationPage(),
        'MyHome': (context) => MyHome(
              sessionId: sessionId,
              vehicleId: vehicleId,
              dashboardData: dashboardData,
              responseData: responseData,
              name: name,
            ),
        'notification': (context) =>
            const NotificationPage(), // Add notification page route
      },
    );
  }
}
