import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:app_settings/app_settings.dart';
import 'package:bike_project/screens/location.dart';
import 'package:bike_project/screens/notification.dart';
import 'package:bike_project/screens/bike_detail.dart';
import 'package:bike_project/screens/profile.dart';
import 'package:bike_project/screens/services.dart';
import 'package:bike_project/screens/support.dart';
import 'package:bike_project/screens/trackmybike.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';

class MyHome extends StatefulWidget {
  final String sessionId;
  final String vehicleId;
  final String name;
  final Map<String, dynamic>? dashboardData;
  final Map<String, dynamic>? responseData;

  const MyHome({
    super.key,
    required this.sessionId,
    required this.vehicleId,
    required this.name,
    this.dashboardData,
    this.responseData,
  });

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool isLoading = true;
  late Timer _timer;
  late FlutterBluePlus flutterBlue;
  bool isBluetoothConnected = false;
  Map<String, dynamic>? screenData;
  DateTime? lastSyncTime;

  @override
  void initState() {
    super.initState();
    fetchScreenData(widget.sessionId, widget.vehicleId);

    // Set up a timer to refresh the data every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchScreenData(widget.sessionId, widget.vehicleId);
    });
  }

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

  String timeAgoSinceLastSync() {
    if (lastSyncTime == null) return 'Last sync';

    final duration = DateTime.now().difference(lastSyncTime!);
    if (duration.inMinutes < 1) {
      return 'just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} mins ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }

  void checkBluetoothConnection() async {
    // Get the list of connected devices asynchronously
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    setState(() {
      // Update the Bluetooth connection status based on connected devices
      isBluetoothConnected = devices.isNotEmpty;
    });

    // Listen for scan results and handle them
    FlutterBluePlus.scanResults.listen((scanResults) {
      setState(() {
        // Update the Bluetooth connection status based on scan results
        isBluetoothConnected = scanResults.isNotEmpty;
      });
    });
  }

  Future<void> fetchScreenData(String sessionId, String vehicleId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://34.93.202.185:5000/api/v1/get_vehicle_dashboard?vehicle_id=$vehicleId&session=$sessionId'),
      );
      print('Response Body: ${response.body}'); // Debugging statement
      if (response.statusCode == 200) {
        setState(() {
          screenData = json.decode(response.body);
          lastSyncTime = DateTime.now(); // Update last sync time
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load dashboard data')),
        );
      }
    } on SocketException {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Internet connection')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Get the arguments from the route
    final bool isCharging = screenData != null &&
        screenData?['data'] != null &&
        screenData?['data'][0]['battery_charge_status'] == 'charging';

    // Extract and decode the profile photo
    Uint8List? profileImage;
    if (screenData != null &&
        screenData!['data'] != null &&
        screenData!['data'][0]['profile_picture'] != null &&
        screenData!['data'][0]['profile_picture']['data'] != null) {
      String base64Image = screenData!['data'][0]['profile_picture']['data'];
      profileImage = base64Decode(base64Image);
    }

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
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
                        width: screenWidth * 0.75,
                        height: screenHeight * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.12,
                      bottom: screenHeight * 0.025,
                      right: screenWidth * 0.13,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //     right: screenWidth * 0.0, // 0% of screen width
                        //   ), // Adjust the padding as needed
                        //   child: IconButton(
                        //     icon: const Icon(
                        //       Icons.arrow_back_ios,
                        //       color: Color.fromARGB(255, 255, 255, 255),
                        //       size: 24,
                        //     ),
                        //     onPressed: () => Navigator.of(context).pop(),
                        //   ),
                        // ),
                        Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: 'Goldman',
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w700,
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
                ],
              ),
              ..._buildListTiles(
                context,
                widget.sessionId,
                widget.vehicleId,
                widget.dashboardData,
                widget.responseData,
              ),
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
                  alignment: const AlignmentDirectional(-0.8, 0),
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
                                angle: 90 * (pi / 180),
                                child: Container(
                                  width: size * 0.56,
                                  height: size * 0.56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      transform:
                                          GradientRotation(-135 * (pi / 180)),
                                      stops: [0.1376, 0.5174, 0.8403, 1.1206],
                                      colors: [
                                        Color(0xFF09545E),
                                        Color(0xFF0C7785),
                                        Color(0x8409545E),
                                        Color(0x8409545E),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(size * 0.125),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                            0.5), // Adjust opacity as needed
                                        offset: const Offset(5,
                                            5), // Shadow is shifted downwards
                                        blurRadius:
                                            8, // Increase blur radius for more spread
                                        spreadRadius:
                                            0, // Shadow size, set to 0 to keep shadow close to the container
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: 180 * (pi / 103),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Builder(
                                                builder: (context) {
                                                  double screenWidth =
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width;
                                                  double baseFontSize = 29;
                                                  double scaledFontSize =
                                                      baseFontSize *
                                                          (screenWidth / 500);

                                                  return Text(
                                                    screenData != null &&
                                                            screenData![
                                                                    'data'] !=
                                                                null
                                                        ? '${screenData!['data'][0]['battery_percentage']}'
                                                        : 'N/A',
                                                    style: TextStyle(
                                                      fontSize: scaledFontSize,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'Ethnocentric',
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
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
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            isCharging
                                                ? 'Charging'
                                                : 'Battery', // Show 'Charging' when charging, otherwise show 'Battery'
                                            style: const TextStyle(
                                              fontFamily: 'Prompt',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
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
                Align(
                  alignment: const AlignmentDirectional(-1.39, 0.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedSquareWave(
                      batteryPercentage:
                          screenData != null && screenData!['data'] != null
                              ? screenData!['data'][0]['battery_percentage']
                              : 0,
                      isCharging: isCharging,
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
                          fontSize: 64,
                          letterSpacing: 0,
                          color: Color(0x532D2A2A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height *
                      0.13, // 10% from the top
                  left: MediaQuery.of(context).size.width *
                      0.38, // 5% from the left
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/image_bike.png',
                        width: MediaQuery.of(context).size.width *
                            0.85, // 80% of screen width
                        height: MediaQuery.of(context).size.height *
                            0.9, // 60% of screen height
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top +
                          25.0, // Adjust as needed
                      right: 15.0, // Adjust as needed
                    ),
                    child: Container(
                      width: 45,
                      height: 45,
                      color:
                          Colors.transparent, // Background color for debugging
                      child: profileImage != null
                          ? ClipOval(
                              child: Image.memory(
                                profileImage!,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 10,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter, // Center at bottom
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 15.0), // Adjust padding
                    child: Text(
                      lastSyncTime != null
                          ? 'Last sync: ${lastSyncTime!.day}/${lastSyncTime!.month}/${lastSyncTime!.year}, ${timeAgoSinceLastSync()}'
                          : 'Last sync',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 8,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height *
                      0.075, // 10% from the top
                  left: 0,
                  right: MediaQuery.of(context).size.width *
                      0.72, // 65% of screen width
                  child: Align(
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/briskhome.png',
                        width: MediaQuery.of(context).size.width *
                            0.4, // 40% of screen width
                        height: MediaQuery.of(context).size.height *
                            0.05, // 5% of screen height
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.075,
                  left: MediaQuery.of(context).size.width * 0.335,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(0), // Padding here is optional
                    child: Text(
                      'Hi ${widget.name}', // Display the user's name here
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 0, 0, 0),
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
                            builder: (context) => const NotificationPage(
                                // sessionId: widget.sessionId,
                                // vehicleId: widget.vehicleId,
                                )),
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
                            sessionId: widget.sessionId,
                            vehicleId: widget.vehicleId,
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
                              screenData != null && screenData!['data'] != null
                                  ? '${screenData!['data'][0]['mode']}'
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 30 *
                                    (MediaQuery.of(context).size.width / 850),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                                color: const Color.fromARGB(208, 23, 234, 0),
                              ),
                            ),
                            const Text(
                              'Mode',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Montserrat',
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
                                  screenData != null &&
                                          screenData!['data'] != null
                                      ? '${screenData!['data'][0]['distance_to_empty']}'
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'KM',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Range',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
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
                      isBluetoothConnected
                          ? 'assets/images/bluetooth_connected.png'
                          : 'assets/images/bluetooth.png',
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
                                    sessionId: widget.sessionId,
                                    vehicleId: widget.vehicleId,
                                  )),
                        );
                      } else {
                        AppSettings.openAppSettings(
                            type: AppSettingsType.location);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    sessionId: widget.sessionId,
                                    vehicleId: widget.vehicleId,
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
                    top: MediaQuery.of(context).size.height * 0.105,
                    left: MediaQuery.of(context).size.width * 0.34,
                  ),
                  child: Text(
                    getGreeting(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
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
    final double imageSize = screenWidth * 0.1; // 6% of screen width
    final double leftPadding =
        screenWidth * 0.12; // Adjust the left padding as needed

    return [
      Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: ListTile(
          contentPadding: EdgeInsets.zero, // Remove default padding
          leading: Image.asset(
            'assets/images/profile.png',
            width: imageSize,
            height: imageSize,
          ),
          title: const Row(
            children: [
              SizedBox(
                  width:
                      10), // Adjust this width to increase the space between image and title
              Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
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
          contentPadding: EdgeInsets.zero, // Remove default padding
          leading: Image.asset(
            'assets/images/service.png',
            width: imageSize,
            height: imageSize,
          ),
          title: const Row(
            children: [
              SizedBox(width: 10), // Adjust this width to control spacing
              Expanded(
                child: Text(
                  'Services',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
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
          contentPadding: EdgeInsets.zero, // Remove default padding
          leading: Image.asset(
            'assets/images/bikedetails.png',
            width: imageSize,
            height: imageSize,
          ),
          title: const Row(
            children: [
              SizedBox(width: 10), // Adjust this width to control spacing
              Expanded(
                child: Text(
                  'Bike Details',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
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
          contentPadding: EdgeInsets.zero, // Remove default padding
          leading: Image.asset(
            'assets/images/support.png',
            width: imageSize,
            height: imageSize,
          ),
          title: const Row(
            children: [
              SizedBox(width: 10), // Adjust this width to control spacing
              Expanded(
                child: Text(
                  'Support',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
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

class AnimatedSquareWave extends StatefulWidget {
  final double batteryPercentage;
  final bool isCharging;

  const AnimatedSquareWave({
    Key? key,
    required this.batteryPercentage,
    required this.isCharging,
  }) : super(key: key);

  @override
  _AnimatedSquareWaveState createState() => _AnimatedSquareWaveState();
}

class _AnimatedSquareWaveState extends State<AnimatedSquareWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isCharging = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    if (widget.isCharging && !_isCharging) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 5), // Slower cycle duration
      )..repeat();
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
      _isCharging = true;
    } else if (!widget.isCharging && _isCharging) {
      _controller.dispose();
      _isCharging = false;
    }
  }

  @override
  void didUpdateWidget(AnimatedSquareWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCharging != oldWidget.isCharging) {
      _initializeAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCharging) {
      return const SizedBox.shrink(); // Hide the widget if not charging
    }

    return Align(
      alignment: const AlignmentDirectional(-1.1, 0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.width * 0.5,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: SquareWavePainter(_animation.value, _controller.value),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isCharging) {
      _controller.dispose();
    }
    super.dispose();
  }
}

class SquareWavePainter extends CustomPainter {
  final double animationValue;
  final double controllerValue; // Use controller value to control timing

  SquareWavePainter(this.animationValue, this.controllerValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.15);

    final maxDimension = size.width;
    final center = Offset(size.width / 2, size.height / 2);
    final angle = 45 * pi / 180; // 45 degrees in radians

    canvas.save(); // Save the current state of the canvas
    canvas.translate(
        center.dx, center.dy); // Move the origin to the center of the canvas
    canvas.rotate(angle); // Rotate the canvas by 45 degrees
    canvas.translate(
        -center.dx, -center.dy); // Move the origin back to the top-left corner

    const squaresCount = 7;

    for (int i = 2; i < squaresCount; i++) {
      // Slow down animation by reducing frequency
      final timeBasedValue =
          (controllerValue * 0.5 * 2 * pi + i * pi / 2) % (2 * pi);
      final dimension = maxDimension *
          (0.5 + 0.5 * sin(timeBasedValue)) *
          (1 - i / squaresCount);
      final offset = (maxDimension - dimension) / 2;
      final rect = Rect.fromLTWH(offset, offset, dimension, dimension);
      final radius = 15.0; // Adjust the radius of the corners

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );
    }

    canvas.restore(); // Restore the saved state of the canvas
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
