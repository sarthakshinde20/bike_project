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
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'screens/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler function
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Add any custom logic here for handling the notification data
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDY28yUcoyaT6_TYbS8xwwVZBpU79_rHFc",
      appId: "1:936541521610:android:1c59831f7882085f3a5633",
      messagingSenderId: "936541521610",
      projectId: "briskev",
      storageBucket: "briskev.appspot.com",
    ),
  );
  await MyFirebaseMessagingService.setupFirebaseMessaging();

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
  // Subscribe to vehicle topic for notifications
  FirebaseMessaging.instance.subscribeToTopic(vehicleId).then((_) {
    print('Subscribed to $vehicleId topic');
  }).catchError((e) {
    print('Error subscribing to $vehicleId: $e');
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

class MyFirebaseMessagingService {
  static Future<void> setupFirebaseMessaging() async {
    // FlutterLocalNotificationsPlugin instance
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Android settings for notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Notification channel settings
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_channel_id', // Unique channel ID
      'My Notifications', // Channel name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Create the notification channel on the device
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }
}
