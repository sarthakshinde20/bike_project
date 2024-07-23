import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class FindMyVehiclePage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  FindMyVehiclePage({required this.sessionId, required this.vehicleId});

  @override
  _FindMyVehiclePageState createState() => _FindMyVehiclePageState();
}

class _FindMyVehiclePageState extends State<FindMyVehiclePage> {
  Map<String, dynamic>? vehicleLocation;
  String? address;

  Future<void> fetchVehicleLocation() async {
    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/vehicle/find_my_vehicle?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );

    if (response.statusCode == 200) {
      final location = json.decode(response.body);
      setState(() {
        vehicleLocation = location;
      });
      await convertCoordinatesToAddress(
          location['latitude'], location['longitude']);
    } else {
      // Handle error
      print('Failed to load vehicle location');
    }
  }

  Future<void> convertCoordinatesToAddress(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        address =
            "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print('Failed to get address: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVehicleLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Location'),
      ),
      body: Center(
        child: vehicleLocation == null
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Vehicle ID: ${widget.vehicleId}'),
                      Text('Session ID: ${widget.sessionId}'),
                      SizedBox(height: 20),
                      Text('Vehicle Location:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(vehicleLocation.toString()),
                      SizedBox(height: 20),
                      address == null
                          ? CircularProgressIndicator()
                          : Text('Address: $address',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
