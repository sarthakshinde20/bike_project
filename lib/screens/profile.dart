import 'dart:io';

import 'package:bike_project/screens/home.dart';
import 'package:bike_project/screens/uploaddocument.dart';
import 'package:flutter/material.dart';

class ProfileModel {
  void dispose() {}
}

class ProfilePage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  ProfilePage({required this.sessionId, required this.vehicleId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileModel _model;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = ProfileModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(-2, -0.9),
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/headline.png',
                    width: screenWidth * 0.9, // 90% of screen width
                    height: screenHeight * 0.3, // 30% of screen height
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.155, // 15% of screen height
                  bottom: screenHeight * 0.025, // 2.5% of screen height
                  right: screenWidth * 0.35, // 35% of screen width
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Goldman',
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 3.0),
                            color: Color.fromARGB(119, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.55,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadImagePage()),
                    );
                  },
                  child: Container(
                    height: 27,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Manage Document',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(255, 32, 32, 32),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-0.77, 0.25),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/images/logout.png',
                                  width: 60.0,
                                  height: 60.0,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                    width:
                                        8), // Adjust spacing between image and text as needed
                                const Flexible(
                                  child: Text(
                                    'Are you sure you want to logout?',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontFamily: 'Raleway',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100, // Adjust width as needed
                                  height: 40, // Adjust height as needed
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green, // Border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => exit(0),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .transparent, // Set transparent color for ElevatedButton
                                      elevation: 0, // Remove elevation
                                    ),
                                    child: const Text(
                                      'Ok',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Raleway',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyLarge!.merge(
                          const TextStyle(
                            fontFamily: 'Raleway',
                            color: Color(0xFFFF693B),
                            fontSize: 19,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0.9),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHome()),
                    );
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
          ),
        ),
      ),
    );
  }
}
