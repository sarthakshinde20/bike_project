import 'package:bike_project/response/locationpage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FindMyVehicle extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  FindMyVehicle({required this.sessionId, required this.vehicleId});

  @override
  _FindMyVehicleState createState() => _FindMyVehicleState();
}

class _FindMyVehicleState extends State<FindMyVehicle> {
  Map<String, dynamic>? vehicleLocation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVehicleLocation();
  }

  Future<void> fetchVehicleLocation() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/vehicle/find_my_vehicle?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        vehicleLocation = {
          'latitude': double.parse(data['data']['latitude'].toString()),
          'longitude': double.parse(data['data']['longitude'].toString()),
        };
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print('Latitude or Longitude not found in response');
    }
  }

  void navigateTolocationPage() {
    if (vehicleLocation != null) {
      final latitude = vehicleLocation!['latitude'];
      final longitude = vehicleLocation!['longitude'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FindMyVehiclePage(
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Location'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  vehicleLocation != null
                      ? Text(
                          'Latitude: ${vehicleLocation!['latitude']}, Longitude: ${vehicleLocation!['longitude']}',
                          style: TextStyle(fontFamily: 'RobotoMono'),
                        )
                      : Text('Location not found'),
                  ElevatedButton(
                    onPressed: navigateTolocationPage,
                    child: Text('Go to Location Page'),
                  ),
                ],
              ),
      ),
    );
  }
}
