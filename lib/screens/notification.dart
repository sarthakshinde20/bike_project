import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // To convert List to String and vice-versa
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key, String? title, String? body})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _loadNotifications(); // Load stored notifications when the app starts
  }

  void _setupFirebaseMessaging() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _firebaseMessaging.getToken().then((String? token) {
      print("Firebase Messaging Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String? title = message.notification!.title;
        String? body = message.notification!.body;

        if (title != null && body != null) {
          final newNotification = {
            "title": title,
            "body": body,
            "time": DateTime.now().toIso8601String(),
          };

          setState(() {
            _notifications.add(newNotification);
          });

          _saveNotifications();
        }
      }
    });
  }

  // Load notifications from SharedPreferences
  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notificationsData = prefs.getString('notifications');

    if (notificationsData != null) {
      List<dynamic> storedNotifications = jsonDecode(notificationsData);
      setState(() {
        _notifications.addAll(storedNotifications
            .map((notification) => Map<String, dynamic>.from(notification))
            .toList());
      });
    }
  }

  // Save notifications to SharedPreferences
  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notifications', jsonEncode(_notifications));
  }

  // Clear notifications from both the UI and SharedPreferences
  void _clearAllNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('notifications'); // Remove notifications from SharedPreferences

    setState(() {
      _notifications.clear(); // Clear the notifications list in the state
    });
  }

  // Filter notifications received in the last 2 days
  List<Map<String, dynamic>> _getRecentNotifications() {
    final now = DateTime.now();
    return _notifications
        .where((notification) =>
            now
                .difference(DateTime.parse(notification['time'] as String))
                .inDays <
            2)
        .toList();
  }

  String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final recentNotifications = _getRecentNotifications();

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Align(
            alignment: const AlignmentDirectional(-2, -0.9),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.85, // 85% of screen width
                height: screenHeight * 0.3, // 30% of screen height
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Notification Header
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.165, // 15% of screen height
              bottom: screenHeight * 0.020, // 2% of screen height
              right: screenWidth * 0.25, // 25% of screen width
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notification',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'Goldman',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 3.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(119, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // "Clear All" Button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0, top: 220.0),
              child: GestureDetector(
                onTap: _notifications.isEmpty ? null : _clearAllNotifications,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 16,
                    color: _notifications.isEmpty
                        ? const Color.fromRGBO(95, 95, 95, 1)
                        : const Color.fromRGBO(
                            95, 95, 95, 1), // Change color as needed
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Raleway',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
          // Notification List
          Padding(
            padding: EdgeInsets.only(
              top: recentNotifications.isEmpty
                  ? screenHeight * 0.10 // Padding for empty state
                  : screenHeight * 0.28, // Padding for notifications list
            ), // Adjust based on image size
            child: recentNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/emptynote.png', // Replace with your image path
                          width: 250, // Adjust the width as needed
                          height: 150, // Adjust the height as needed
                        ),
                        const Text(
                          'Your Inbox is Empty',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: recentNotifications.length,
                    itemBuilder: (context, index) {
                      // Reverse the list to show the latest notifications first
                      final notification = recentNotifications[
                          recentNotifications.length - 1 - index];
                      final notificationTime =
                          timeAgo(DateTime.parse(notification['time']));

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: const Color.fromARGB(
                                  255, 0, 0, 0), // Border color
                              width: 1, // Border width
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              notification['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Align items in the row
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification['body'],
                                        style: const TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    width: 8), // Spacing between text and icon
                                Row(
                                  children: [
                                    Text(
                                      notificationTime,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(175, 0, 0, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Home Button
          Align(
            alignment: const AlignmentDirectional(0, 0.95),
            child: GestureDetector(
              onTap: () {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 1);
              },
              child: SizedBox(
                width: screenWidth * 0.14,
                height: screenWidth * 0.14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/home.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
