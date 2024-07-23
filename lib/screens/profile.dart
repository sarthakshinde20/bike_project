import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bike_project/screens/editprofile.dart';
import 'package:bike_project/screens/home.dart';

class ProfileModel {
  void dispose() {}
}

class ProfilePage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  const ProfilePage(
      {super.key, required this.sessionId, required this.vehicleId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileModel _model;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? userDetails;

  Future<void> fetchUserDetails() async {
    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/get_user_details?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        userDetails = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load user details');
    }
  }

  @override
  void initState() {
    super.initState();
    _model = ProfileModel();
    fetchUserDetails();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildHeadlineImage(double screenWidth, double screenHeight) {
    return Align(
      alignment: const AlignmentDirectional(-2, -0.9),
      child: ClipRRect(
        child: Image.asset(
          'assets/images/headline.png',
          width: screenWidth * 0.9,
          height: screenHeight * 0.3,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProfileTitle(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenHeight * 0.155,
        bottom: screenHeight * 0.025,
        right: screenWidth * 0.35,
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
    );
  }

  Widget _buildManageDocumentButton(double screenWidth, double screenHeight) {
    return Positioned(
      top: screenHeight * 0.55,
      left: screenWidth * 0.1,
      right: screenWidth * 0.1,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EditProfilePage(
                      sessionId: '',
                      vehicleId: '',
                    )),
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
    );
  }

  Widget _buildLogoutButton() {
    return Align(
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
                      const SizedBox(width: 8),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green,
                            width: 2.0,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => exit(0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          child: const Text(
                            'Ok',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
    );
  }

  Widget _buildHomeButton(double screenWidth) {
    return Align(
      alignment: const AlignmentDirectional(0, 0.9),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHome()),
          );
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
    );
  }

  Widget _buildUserDetails() {
    if (userDetails == null) {
      return const CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vehicle ID: ${widget.vehicleId}'),
        Text('Session ID: ${widget.sessionId}'),
        const SizedBox(height: 20),
        const Text('User Details:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (userDetails != null) ...[
          if (userDetails!['profile_picture'] != null)
            Image.network(userDetails!['profile_picture']),
          if (userDetails!['user_name'] != null)
            Text('Name: ${userDetails!['user_name']}'),
          if (userDetails!['phone_number'] != null)
            Text('Phone: ${userDetails!['phone_number']}'),
        ] else
          const Text('No user details available'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Stack(
            children: [
              _buildHeadlineImage(screenWidth, screenHeight),
              _buildProfileTitle(screenWidth, screenHeight),
              _buildManageDocumentButton(screenWidth, screenHeight),
              _buildLogoutButton(),
              _buildHomeButton(screenWidth),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.35),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildUserDetails(),
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
