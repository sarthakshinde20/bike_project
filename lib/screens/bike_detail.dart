import 'package:bike_project/screens/home.dart';
import 'package:flutter/material.dart';

class BikeDetailsPage extends StatelessWidget {
  final String sessionId;
  final String vehicleId;
  final Map<String, dynamic>? responseData;
  final Map<String, dynamic>? dashboardData;

  const BikeDetailsPage({
    Key? key,
    required this.sessionId,
    required this.vehicleId,
    this.responseData,
    this.dashboardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Default values
    String vehicleColorDashboardData = 'Not available';
    String motorNumberDashboardData = 'Not available';
    String vehicleModelDashboardData = 'Not available';
    String vinNumberDashboardData = 'Not available';
    String vehicleIdDashboardData = 'Not available';

    // Extract vehicle details from dashboardData
    if (dashboardData != null && dashboardData is Map<String, dynamic>) {
      var vehicles = dashboardData!['vehicles'] as List<dynamic>?;
      if (vehicles != null && vehicles.isNotEmpty) {
        var firstVehicle = vehicles[0] as Map<String, dynamic>?;
        vehicleColorDashboardData =
            firstVehicle?['vehicle_color'] ?? 'Not available';
        motorNumberDashboardData =
            firstVehicle?['motor_number'] ?? 'Not available';
        vehicleModelDashboardData =
            firstVehicle?['vehicle_model'] ?? 'Not available';
        vinNumberDashboardData = firstVehicle?['vin_number'] ?? 'Not available';
        vehicleIdDashboardData = firstVehicle?['vehicle_id'] ?? 'Not available';
      }
    }

    // Print values for debugging
    print('Vehicle Color from dashboardData: $vehicleColorDashboardData');
    print('Motor Number from dashboardData: $motorNumberDashboardData');
    print('Vehicle Model from dashboardData: $vehicleModelDashboardData');
    print('VIN Number from dashboardData: $vinNumberDashboardData');
    print('Vehicle ID from dashboardData: $vehicleIdDashboardData');

    return Scaffold(
      body: Stack(
        children: [
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
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.155,
              bottom: screenHeight * 0.025,
              right: screenWidth * 0.22,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bike Details',
                  style: TextStyle(
                    fontSize: 34,
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
            alignment: const AlignmentDirectional(0, -0.15),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/bike_rectangle.png',
                width: screenWidth * 0.9,
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(4.5, -0.2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/detailsbike.png',
                width: screenWidth * 0.85,
                height: screenHeight * 0.45,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-0.65, -0.25),
            child: Text(
              vehicleModelDashboardData,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const Align(
            alignment: AlignmentDirectional(-0.68, -0.16),
            child: Text(
              'Model Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-0.72, -0.05),
            child: Text(
              vehicleColorDashboardData,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const Align(
            alignment: AlignmentDirectional(-0.72, 0.05),
            child: Text(
              'Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const Align(
            alignment: AlignmentDirectional(-0.75, 0.3),
            child: Text(
              'Model number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.75, 0.3),
            child: Text(
              motorNumberDashboardData,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const Align(
            alignment: AlignmentDirectional(-0.77, 0.4),
            child: Text(
              'Vin number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.75, 0.4),
            child: Text(
              vinNumberDashboardData,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const Align(
            alignment: AlignmentDirectional(-0.8, 0.5),
            child: Text(
              'Motor no',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.75, 0.5),
            child: Text(
              vehicleIdDashboardData,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.9),
            child: GestureDetector(
              onTap: () {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
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
    );
  }
}
