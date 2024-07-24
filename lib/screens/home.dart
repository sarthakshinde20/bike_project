import 'package:app_settings/app_settings.dart';
import 'package:bike_project/screens/bike_detail.dart';
import 'package:bike_project/screens/location.dart';
import 'package:bike_project/screens/notification.dart';
import 'package:bike_project/screens/profile.dart';
import 'package:bike_project/screens/services.dart';
import 'package:bike_project/screens/support.dart';
import 'package:bike_project/screens/tire_health.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MyHome extends StatelessWidget {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 1 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 16) {
      return 'Good Afternoon!';
    } else if (hour >= 16 && hour < 23) {
      return 'Good Evening!';
    } else {
      return 'Good Day!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Get the arguments from the route
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String sessionId = args['sessionId'] as String? ?? 'No session ID';
    final String vehicleId = args['vehicleId'] as String? ?? 'No vehicle ID';
    final Map<String, dynamic>? dashboardData =
        args['dashboardData'] as Map<String, dynamic>?;

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: screenWidth * 0.0, // 0% of screen width
                        ), // Adjust the padding as needed
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Goldman',
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(3.0, 4.0),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          double size = constraints.maxWidth * 0.5;

          return Stack(
            children: [
              Align(
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
                      transform: GradientRotation(90.3 * (pi / 90)),
                      stops: [0.0, 0.7103, 1.1206],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.rotate(
                  angle: 45 * (pi / 180),
                  child: Container(
                    width: size * 0.86,
                    height: size * 0.86,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(86.62 * (pi / 90)),
                        stops: [0.2505, 0.7943, 1.2565, 1.658],
                        colors: [
                          Color(0xFF09545E),
                          Color(0xFF0C7785),
                          Color.fromRGBO(9, 84, 94, 0.517708),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(size * 0.26),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -90 * (pi / 180),
                        child: Container(
                          width: size * 0.715,
                          height: size * 0.715,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(size * 0.15),
                          ),
                          child: Center(
                            child: Transform.rotate(
                              angle: 90 * (pi / 90),
                              child: Container(
                                width: size * 0.56,
                                height: size * 0.56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    transform:
                                        GradientRotation(90.3 * (pi / 90)),
                                    stops: [0.1376, 0.5174, 0.8403, 1.1206],
                                    colors: [
                                      Color(0xFF09545E),
                                      Color(0xFF0C7785),
                                      Color.fromRGBO(9, 84, 94, 0.517708),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(size * 0.125),
                                ),
                                child: Center(
                                  child: Transform.rotate(
                                    angle: 135 *
                                        (pi /
                                            108), // Corrected the angle calculation
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              dashboardData != null &&
                                                      dashboardData!['data'] !=
                                                          null
                                                  ? '${dashboardData!['data'][0]['battery_percentage']}'
                                                  : 'N/A',
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Ethnocentric',
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              '%',
                                              style: TextStyle(
                                                fontFamily: 'Ethnocentric',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Text(
                                          'Battery',
                                          style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Colors.white),
                                        ),
                                      ],
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
              ),
              Positioned(
                top: MediaQuery.of(context).size.height *
                    0.7, // Adjust as needed
                left: 0,
                right: -20,
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: -90 * (pi / 180),
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
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    MediaQuery.of(context).size.width > 600
                        ? 185
                        : 185, 
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
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                left: 35,
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
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.16,
                  left: MediaQuery.of(context).size.width * 0.08,
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
                  top: MediaQuery.of(context).size.height * 0.24,
                  left: MediaQuery.of(context).size.width * 0.08,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => const NotificationPage()),
                    // );
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
                  top: MediaQuery.of(context).size.height * 0.32,
                  left: MediaQuery.of(context).size.width * 0.08,
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
                  top: MediaQuery.of(context).size.height * 0.62,
                  left: MediaQuery.of(context).size.width * 0.06,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Image.asset(
                    'assets/images/ecomode.png',
                    width: MediaQuery.of(context).size.width * 0.16,
                    height: MediaQuery.of(context).size.width * 0.16,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.715,
                  left: MediaQuery.of(context).size.width * 0.06,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/range.png',
                        width: MediaQuery.of(context).size.width * 0.16,
                        height: MediaQuery.of(context).size.width * 0.16,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dashboardData != null &&
                                        dashboardData!['data'] != null
                                    ? '${dashboardData!['data'][0]['distance_to_empty']}'
                                    : 'N/A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Goldman',
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'KM',
                                style: TextStyle(
                                  fontFamily: 'Goldman',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Range',
                            style: TextStyle(
                              fontFamily: 'Goldman',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.81,
                  left: MediaQuery.of(context).size.width * 0.08,
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
                  top: MediaQuery.of(context).size.height * 0.89,
                  left: MediaQuery.of(context).size.width * 0.08,
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
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: MediaQuery.of(context).size.width * 0.34,
                ),
                child: Text(
                  getGreeting(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Goldman',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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

  List<Widget> _buildListTiles(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'image': 'assets/images/profile.png',
        'title': 'Profile',
        // 'page': const ProfilePage()
      },
      {
        'image': 'assets/images/service.png',
        'title': 'Services',
//        'page': const servicesPage()
      },
      {
        'image': 'assets/images/tirehealth.png',
        'title': 'Tyre Health',
        //  'page': const TireHealthPage()
      },
      {
        'image': 'assets/images/trackmybike.png',
        'title': 'Track MyBike',
        //  'page': const LocateBikePage()
      },
      {
        'image': 'assets/images/bikedetails.png',
        'title': 'Bike Details',
        // 'page': const BikeDetailsPage()
      },
      {
        'image': 'assets/images/support.png',
        'title': 'Support',
        // 'page': const SupportPage()
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
}
