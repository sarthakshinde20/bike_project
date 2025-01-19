import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class notificationcontrolle extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;

  static notificationcontrolle get instance => Get.find();

  @override
  void onInit() {
    super.onInit();
    setupFirebaseMessaging();
    _loadNotifications();
  }

  Future<void> setupFirebaseMessaging() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_channel_id', // Unique channel ID
      'My Notifications', // Channel name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getToken().then((String? token) {
      print("Firebase Messaging Token: $token");
    });

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

        String? title = message.notification!.title;
        String? body = message.notification!.body;

        if (title != null && body != null) {
          final newNotification = {
            "title": title,
            "body": body,
            "time": DateTime.now().toIso8601String(),
          };

          notifications.add(newNotification);

          _saveNotifications();
        }
      }
    });

    // Handle background and closed state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked while app was in background or closed.');
      // storeNotification(message);
    });
  }

  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notificationsData = prefs.getString('notifications');

    if (notificationsData != null) {
      List<dynamic> storedNotifications = jsonDecode(notificationsData);
      notifications.addAll(storedNotifications
          .map((notification) => Map<String, dynamic>.from(notification))
          .toList());
    }
  }

  // Save notifications to SharedPreferences
  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notifications', jsonEncode(notifications));
  }

  // Clear notifications
  void clearAllNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');

    notifications.clear();
  }

  // Filter recent notifications (within last 2 days)
  List<Map<String, dynamic>> getRecentNotifications() {
    final now = DateTime.now();
    return notifications.where((notification) {
      return now
              .difference(DateTime.parse(notification['time'] as String))
              .inDays <
          2;
    }).toList();
  }
}
