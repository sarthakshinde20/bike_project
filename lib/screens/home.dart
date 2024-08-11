import 'package:app_settings/app_settings.dart';
import 'package:bike_project/screens/trackmybike.dart';
import 'package:bike_project/screens/bike_detail.dart';
import 'package:bike_project/screens/location.dart';
import 'package:bike_project/screens/notification.dart';
import 'package:bike_project/screens/profile.dart';
import 'package:bike_project/screens/services.dart';
import 'package:bike_project/screens/support.dart';
import 'package:bike_project/screens/tire_health.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class MyHome extends StatelessWidget {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
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
    final Map<String, dynamic>? responseData =
        args['responseData'] as Map<String, dynamic>?;

    return WillPopScope(
      onWillPop: () async {
        // Exiting the app
        SystemNavigator.pop();
        return false; // Return false to prevent the default back navigation
      },
      child: Scaffold(
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
              ..._buildListTiles(
                  context, sessionId, vehicleId, dashboardData, responseData),
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
                                              Builder(
                                                builder: (context) {
                                                  // Use MediaQuery to get the screen width
                                                  double screenWidth =
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width;

                                                  // Define a base font size and scale it based on screen width
                                                  double baseFontSize = 30;
                                                  double scaledFontSize =
                                                      baseFontSize *
                                                          (screenWidth /
                                                              500); // Adjust 375 based on your design's base width

                                                  return Text(
                                                    dashboardData != null &&
                                                            dashboardData![
                                                                    'data'] !=
                                                                null
                                                        ? '${dashboardData!['data'][0]['battery_percentage']}'
                                                        : 'N/A',
                                                    style: TextStyle(
                                                      fontSize: scaledFontSize,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'Ethnocentric',
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                },
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
                      MediaQuery.of(context).size.width > 600 ? 185 : 185,
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
                    top: MediaQuery.of(context).size.height * 0.32,
                    left: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindMyVehicle(
                            sessionId: sessionId,
                            vehicleId: vehicleId,
                          ),
                        ),
                      );
                      // showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return Theme(
                      //       data: Theme.of(context).copyWith(
                      //         dialogBackgroundColor: Colors.white,
                      //       ),
                      //       child: AlertDialog(
                      //         content: Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             Padding(
                      //               padding: const EdgeInsets.only(top: 20.0),
                      //               child: Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceEvenly,
                      //                 children: [
                      //                   _buildDialogOption(
                      //                     'assets/images/horn.png',
                      //                     'Horn',
                      //                     () {},
                      //                     MediaQuery.of(context).size.width,
                      //                   ),
                      //                   _buildDialogOption(
                      //                     'assets/images/light.png',
                      //                     'Turn ON lights',
                      //                     () {},
                      //                     MediaQuery.of(context).size.width,
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //             const SizedBox(height: 20),
                      //             Center(
                      //               child: Column(
                      //                 mainAxisSize: MainAxisSize.min,
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   const SizedBox(height: 10),
                      //                   TextButton(
                      //                     onPressed: () {
                      //                       Navigator.of(context).pop();
                      //                     },
                      //                     style: TextButton.styleFrom(
                      //                       padding: EdgeInsets.zero,
                      //                     ),
                      //                     child: Container(
                      //                       width: 100,
                      //                       height: 50,
                      //                       decoration: BoxDecoration(
                      //                         border: Border.all(
                      //                           color: const Color.fromARGB(
                      //                               255, 9, 84, 94),
                      //                           width: 2.0,
                      //                         ),
                      //                         borderRadius:
                      //                             BorderRadius.circular(35),
                      //                       ),
                      //                       alignment: Alignment.center,
                      //                       child: const Text(
                      //                         "Cancel",
                      //                         style: TextStyle(
                      //                           color: Color.fromARGB(
                      //                               255, 9, 84, 94),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );
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
                    left: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/range.png',
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.width * 0.18,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dashboardData != null &&
                                      dashboardData!['data'] != null
                                  ? '${dashboardData!['data'][0]['mode']}'
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 30 *
                                    (MediaQuery.of(context).size.width / 850),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Goldman',
                                color: const Color.fromARGB(208, 23, 234, 0),
                              ),
                            ),
                            Text(
                              'Mode',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                fontFamily: 'Goldman',
                                fontWeight: FontWeight.w400,
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
                    top: MediaQuery.of(context).size.height * 0.715,
                    left: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/range.png',
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.width * 0.18,
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
                    onTap: () async {
                      bool locationEnabled =
                          await Geolocator.isLocationServiceEnabled();

                      if (locationEnabled) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    sessionId: sessionId,
                                    vehicleId: vehicleId,
                                  )),
                        );
                      } else {
                        AppSettings.openAppSettings(
                            type: AppSettingsType.location);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    sessionId: sessionId,
                                    vehicleId: vehicleId,
                                  )),
                        );
                      }
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
                    style: const TextStyle(
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

  List<Widget> _buildListTiles(
    BuildContext context,
    String sessionId,
    String vehicleId,
    Map<String, dynamic>? responseData,
    Map<String, dynamic>? dashboardData,
  ) {
    // Get the screen width and height
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Define image size based on screen width
    final double imageSize = screenWidth * 0.09; // 6% of screen width
    final double leftPadding =
        screenWidth * 0.05; // Adjust the left padding as needed

    return [
      Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: ListTile(
          leading: Image.asset('assets/images/profile.png',
              width: imageSize, height: imageSize),
          title: const Text('Profile',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  fontSize: 20)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                sessionId: sessionId,
                vehicleId: vehicleId,
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: ListTile(
          leading: Image.asset('assets/images/service.png',
              width: imageSize, height: imageSize),
          title: const Text('Services',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  fontSize: 20)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const servicesPage(),
            ),
          ),
        ),
      ),
      // Padding(
      //   padding: EdgeInsets.only(left: leftPadding),
      //   child: ListTile(
      //     leading: Image.asset('assets/images/tirehealth.png',
      //         width: imageSize, height: imageSize),
      //     title: const Text('Tyre Health',
      //         style: const TextStyle(
      //             fontFamily: 'Raleway',
      //             fontWeight: FontWeight.w600,
      //             fontSize: 20)),
      //     onTap: () => Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const TireHealthPage(),
      //       ),
      //     ),
      //   ),
      // ),
      // Padding(
      //   padding: EdgeInsets.only(left: leftPadding),
      //   child: ListTile(
      //     leading: Image.asset('assets/images/trackmybike.png',
      //         width: imageSize, height: imageSize),
      //     title: const Text('Track MyBike',
      //         style: const TextStyle(
      //             fontFamily: 'Raleway',
      //             fontWeight: FontWeight.w600,
      //             fontSize: 20)),
      //     onTap: () => Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) =>
      //             FindMyVehicle(sessionId: sessionId, vehicleId: vehicleId),
      //       ),
      //     ),
      //   ),
      // ),
      Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: ListTile(
          leading: Image.asset('assets/images/bikedetails.png',
              width: imageSize, height: imageSize),
          title: const Text('Bike Details',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  fontSize: 20)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BikeDetailsPage(
                sessionId: sessionId,
                vehicleId: vehicleId,
                responseData: responseData,
                dashboardData: dashboardData,
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: ListTile(
          leading: Image.asset('assets/images/support.png',
              width: imageSize, height: imageSize),
          title: const Text('Support',
              style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                  fontSize: 20)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SupportPage(),
            ),
          ),
        ),
      ),
    ];
  }
}
