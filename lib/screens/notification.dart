import 'package:bike_project/response/notif.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final recentNotifications =
          notificationcontrolle.instance.getRecentNotifications();
      return Stack(
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
                onTap: notificationcontrolle.instance.notifications.isEmpty
                    ? null
                    : notificationcontrolle.instance.clearAllNotifications,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 16,
                    color: notificationcontrolle.instance.notifications.isEmpty
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
            alignment: const AlignmentDirectional(0, 0.9),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
        ],
      );
    }));
  }
}
