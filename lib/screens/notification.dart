import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    // Request notification permissions
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Get the Firebase token for this device
    _firebaseMessaging.getToken().then((String? token) {
      print("Firebase Messaging Token: $token");
    });

    // Handle when app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message in the foreground!");

      if (message.notification != null) {
        print('Notification title: ${message.notification!.title}');
        print('Notification body: ${message.notification!.body}');
        setState(() {
          // Add notification title to the list
          _notifications.add(message.notification!.title ?? "No title");
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      body: Stack(children: [
        Align(
          alignment: const AlignmentDirectional(-2, -0.9),
          child: ClipRRect(
            child: Image.asset(
              'assets/images/headline.png',
              width: screenWidth * 0.85, // 90% of screen width
              height: screenHeight * 0.3, // 30% of screen height
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.165, // 15% of screen height
            bottom: screenHeight * 0.020, // 2.5% of screen height
            right: screenWidth * 0.25, // 35% of screen width
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Notification',
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Goldman',
                  color: Color.fromARGB(255, 255, 255, 255),
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
        Align(
          alignment: const AlignmentDirectional(0, 0.95),
          child: GestureDetector(
            onTap: () {
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 1);
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.14,
              height: MediaQuery.of(context).size.width * 0.14,
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
        _notifications.isEmpty
            ? const Center(
                child: Text(
                'Your Inbox is Empty',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ))
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notifications[index]),
                  );
                },
              ),
      ]),
    );
  }
}
