import 'package:bike_project/response/dashboardpage.dart';
import 'package:bike_project/response/find_my_vehicle.dart';
import 'package:bike_project/response/get_user_details.dart';
import 'package:bike_project/response/homepage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class ResponsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responseBody =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'No response';

    Map<String, dynamic> responseJson = {};
    try {
      responseJson = jsonDecode(responseBody);
    } catch (e) {
      print('Error decoding JSON: $e');
      responseJson = {
        'error': 'Invalid response format',
        'responseBody': responseBody,
      };
    }

    final sessionId = responseJson['session_id'] ?? '';
    final vehicleId =
        responseJson['vehicles'] != null && responseJson['vehicles'].isNotEmpty
            ? responseJson['vehicles'][0]['vehicle_id'] ?? ''
            : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Response Body: $responseBody'),
            if (responseJson.containsKey('error'))
              Text('Error: ${responseJson['error']}'),
            const SizedBox(height: 20),
            if (!responseJson.containsKey('error')) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        sessionId: sessionId,
                        vehicleId: vehicleId,
                      ),
                    ),
                  );
                },
                child: const Text('Go to Home Page'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(
                        sessionId: sessionId,
                        vehicleId: vehicleId,
                      ),
                    ),
                  );
                },
                child: const Text('Go to Vehicle Dashboard'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GetUserDetailsPage(
                        sessionId: sessionId,
                        vehicleId: vehicleId,
                      ),
                    ),
                  );
                },
                child: const Text('Go to Get User Details'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindMyVehicle(
                        sessionId: sessionId,
                        vehicleId: vehicleId,
                      ),
                    ),
                  );
                },
                child: const Text('Go to Find My Vehicle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
