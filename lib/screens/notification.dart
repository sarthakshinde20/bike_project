import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final List<Map<String, dynamic>> _notifications = [];
  late StreamSubscription<RemoteMessage> _messageSubscription;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _loadNotifications();
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

    // Listen to foreground messages
    _messageSubscription =
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

          if (mounted) {
            setState(() {
              _notifications.add(newNotification);
            });
          }

          _saveNotifications();
        }
      }
    });

    // Handle background messages
    // FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get stored notifications, handle decoding in case of an empty or corrupted JSON
    List<dynamic> storedNotifications;
    try {
      final String? notificationsData = prefs.getString('notifications');
      storedNotifications = notificationsData != null
          ? jsonDecode(notificationsData) as List<dynamic>
          : [];
    } catch (e) {
      print('Error decoding notifications: $e');
      storedNotifications = [];
    }

    // Prepare the new notification with title, body, and current time
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    if (title != null && body != null) {
      final newNotification = {
        "title": title,
        "body": body,
        "time": DateTime.now().toIso8601String(),
      };

      // Add the new notification to the list and save it back to SharedPreferences
      storedNotifications.add(newNotification);
      await prefs.setString('notifications', jsonEncode(storedNotifications));
    }
  }

  // Load notifications from SharedPreferences
  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notificationsData = prefs.getString('notifications');

    if (notificationsData != null) {
      List<dynamic> storedNotifications = jsonDecode(notificationsData);
      if (mounted) {
        setState(() {
          _notifications.addAll(storedNotifications
              .map((notification) => Map<String, dynamic>.from(notification))
              .toList());
        });
      }
    }
  }

  // Save notifications to SharedPreferences
  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notifications', jsonEncode(_notifications));
  }

  // Clear notifications
  void _clearAllNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');

    if (mounted) {
      setState(() {
        _notifications.clear();
      });
    }
  }

  // Filter recent notifications (within last 2 days)
  List<Map<String, dynamic>> _getRecentNotifications() {
    final now = DateTime.now();
    return _notifications.where((notification) {
      return now
              .difference(DateTime.parse(notification['time'] as String))
              .inDays <
          2;
    }).toList();
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
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
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
                width: screenWidth * 0.85,
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Notification Header
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.165,
              bottom: screenHeight * 0.020,
              right: screenWidth * 0.25,
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
                        : const Color.fromRGBO(95, 95, 95, 1),
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
                  ? screenHeight * 0.10
                  : screenHeight * 0.31,
            ),
            child: recentNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/emptynote.png',
                          width: 250,
                          height: 150,
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
                      final notification = recentNotifications[
                          recentNotifications.length - 1 - index];
                      final notificationTime =
                          timeAgo(DateTime.parse(notification['time']));

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Navigator.pop(context);
              },
              child: ClipOval(
                child: Container(
                  color: Colors.blue,
                  padding: const EdgeInsets.all(15),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 30,
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
