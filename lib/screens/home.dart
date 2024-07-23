import 'package:app_settings/app_settings.dart';
import 'package:bike_project/screens/response.dart';
import 'package:bike_project/screens/bike_detail.dart';
import 'package:bike_project/screens/locate_bike.dart';
import 'package:bike_project/screens/location.dart';
import 'package:bike_project/screens/notification.dart';
import 'package:bike_project/screens/profile.dart';
import 'dart:convert';
import 'package:bike_project/screens/support.dart';
import 'package:bike_project/screens/tire_health.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);
  static const platform = MethodChannel('com.example.bike_project/bluetooth');

  Future<void> _enableBluetooth() async {
    try {
      await platform.invokeMethod('enableBluetooth');
    } on PlatformException catch (e) {
      print("Failed to enable Bluetooth: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final responseBody = ModalRoute.of(context)?.settings.arguments;

    Map<String, dynamic> responseJson = {};
    if (responseBody is String) {
      // If the responseBody is a String, try to decode it
      try {
        responseJson = jsonDecode(responseBody);
      } catch (e) {
        print('Error decoding JSON: $e');
        responseJson = {
          'error': 'Invalid response format',
          'responseBody': responseBody,
        };
      }
    } else if (responseBody is Map<String, dynamic>) {
      // If the responseBody is already a Map
      responseJson = responseBody;
    } else {
      // If the responseBody is neither String nor Map
      responseJson = {
        'error': 'Invalid response type',
        'responseBody': responseBody.toString(),
      };
    }

    final sessionId = responseJson['session_id'] ?? '';
    final vehicleId =
        responseJson['vehicles'] != null && responseJson['vehicles'].isNotEmpty
            ? responseJson['vehicles'][0]['vehicle_id'] ?? ''
            : '';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(-2, -0.9),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/images/headline.png',
                      width: screenWidth * 0.82, // 90% of screen width
                      height: screenHeight * 0.3, // 30% of screen height
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.12, // 15% of screen height
                    bottom: screenHeight * 0.025, // 2.5% of screen height
                    right: screenWidth * 0.25, // 35% of screen width
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Goldman',
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
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
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 110.0, bottom: 115, left: 80.0),
                  ),
                ),
              ],
            ),
            ..._buildListTiles(context),
          ],
        ),
      ),
      body: const SafeArea(child: HomePageContent()),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.11,
                  left: MediaQuery.of(context).size.width * 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Image.asset(
                    'assets/images/menu.png',
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.01,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationPage()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/notification.png',
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.015,
                ),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildDialogOption(
                                        'assets/images/horn.png',
                                        'Horn',
                                        () {},
                                        MediaQuery.of(context).size.width,
                                      ),
                                      _buildDialogOption(
                                        'assets/images/light.png',
                                        'Turn ON lights',
                                        () {},
                                        MediaQuery.of(context).size.width,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Container(
                                          width: 100,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 9, 84, 94),
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 9, 84, 94),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Image.asset(
                    'assets/images/bikefuction.png',
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.41,
                  left: MediaQuery.of(context).size.width * 0.01,
                ),
                child: GestureDetector(
                  onTap: () => AppSettings.openAppSettings(
                      type: AppSettingsType.bluetooth),
                  child: Image.asset(
                    'assets/images/bluetooth.png',
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.015,
                ),
                child: GestureDetector(
                  onTap: () {
                    AppSettings.openAppSettings(type: AppSettingsType.location);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/location.png',
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  List<Widget> _buildListTiles(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'image': 'assets/images/profile.png',
        'title': 'Profile',
        'page': const ProfilePage(
          sessionId: '',
          vehicleId: '',
        )
      },
      {
        'image': 'assets/images/service.png',
        'title': 'Services',
        'page': ResponsePage()
      },
      {
        'image': 'assets/images/tirehealth.png',
        'title': 'Tyre Health',
        'page': const TireHealthPage()
      },
      {
        'image': 'assets/images/trackmybike.png',
        'title': 'Track MyBike',
        'page': const LocateBikePage()
      },
      {
        'image': 'assets/images/bikedetails.png',
        'title': 'Bike Details',
        'page': const BikeDetailsPage()
      },
      {
        'image': 'assets/images/support.png',
        'title': 'Support',
        'page': const SupportPage()
      },
    ];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0, left: 16.0),
        child: ListTile(
          leading: SizedBox(
            width: MediaQuery.of(context).size.width * 0.09, // Responsive size
            height: MediaQuery.of(context).size.width * 0.09, // Responsive size
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                item['image'],
                width: MediaQuery.of(context).size.width * 0.09,
                height: MediaQuery.of(context).size.width * 0.09,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(item['title'],
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  fontSize: 19)), // Responsive text size
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    item['page'],
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildDialogOption(String imagePath, String label,
      VoidCallback onPressed, double deviceWidth) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 254, 254),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage(imagePath),
              width:
                  deviceWidth * 0.07, // Adjust the size of the image as needed
              height:
                  deviceWidth * 0.07, // Adjust the size of the image as needed
            ),
            SizedBox(
                height:
                    deviceWidth * 0.02), // Add spacing between image and text
            Text(
              label,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: GradientBox(),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height * 0.7, // Adjust as needed
            left: 0,
            right: -20,
            child: Align(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: -90 * (3.1415926535897932 / 180),
                child: const Text(
                  'Origin',
                  style: TextStyle(
                    fontFamily: 'ethnocentric',
                    fontSize: 54,
                    letterSpacing: 0,
                    color: Color(0x532D2A2A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              MediaQuery.of(context).size.width > 600
                  ? 185
                  : 185, // Adjusted horizontal padding for larger screens
              0,
              0,
              0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/image_bike.png',
                width: 420,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        ),
        Positioned(
          top: 30,
          left: 40,
          right: 0,
          child: Align(
            child: ClipRRect(
              child: Image.asset(
                'assets/images/briskhome.png',
                width: 160,
                height: 18,
              ),
            ),
          ),
        ),
        Center(
          child: DashPrintPage(dashboardData: {}),
        ),
      ],
    );
  }
}

class GradientBox extends StatelessWidget {
  const GradientBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 100,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(9, 84, 94, 0.517708),
              Color(0xFF0C7785),
              Color(0xFF09545E),
            ],
            transform: GradientRotation(90.3 * (3.1415927 / 90)),
            stops: [0.0, 0.7103, 1.1206],
          ),
        ),
      ),
    );
  }
}

class DashPrintPage extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  DashPrintPage({required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth * 0.5;

        return Align(
          alignment: Alignment.centerLeft,
          child: Transform.rotate(
            angle: 45 * (3.1415927 / 180),
            child: Container(
              width: size * 0.83,
              height: size * 0.83,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(86.62 * (3.1415927 / 90)),
                  stops: [0.2505, 0.7943, 1.2565, 1.658],
                  colors: [
                    Color(0xFF09545E),
                    Color(0xFF0C7785),
                    Color.fromRGBO(9, 84, 94, 0.517708),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.175),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -90 * (3.1415927 / 180),
                  child: Container(
                    width: size * 0.7,
                    height: size * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size * 0.125),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: 90 * (3.1415927 / 90),
                        child: Container(
                          width: size * 0.6,
                          height: size * 0.6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              transform:
                                  GradientRotation(90.3 * (3.1415927 / 90)),
                              stops: [0.1376, 0.5174, 0.8403, 1.1206],
                              colors: [
                                Color(0xFF09545E),
                                Color(0xFF0C7785),
                                Color.fromRGBO(9, 84, 94, 0.517708),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(size * 0.125),
                          ),
                          child: Center(
                            child: Text(
                              dashboardData != null &&
                                      dashboardData['data'] != null &&
                                      dashboardData['data'].isNotEmpty &&
                                      dashboardData['data'][0]
                                              ['battery_percentage'] !=
                                          null
                                  ? '${dashboardData['data'][0]['battery_percentage']}%'
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.lineTo(size.width, size.height - 40); // Bottom right cut
    path.lineTo(size.width - 85, size.height); // Bottom right corner
    path.lineTo(0, size.height); // Bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
