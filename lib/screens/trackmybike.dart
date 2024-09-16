import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class FindMyVehicle extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  FindMyVehicle({
    required this.sessionId,
    required this.vehicleId,
    Map<String, dynamic>? dashboardData,
  });

  @override
  _FindMyVehicleState createState() => _FindMyVehicleState();
}

class _FindMyVehicleState extends State<FindMyVehicle> {
  Map<String, dynamic>? vehicleLocation;
  LatLng? userLocation;
  bool isLoading = true;
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late GoogleMapController mapController;
  final String googleApiKey =
      'AIzaSyDIEuHp8fW56w3FpPw02icU6TtmRkKxYm4'; // Add your API key here

  @override
  void initState() {
    super.initState();
    fetchVehicleLocation();
  }

  Future<void> fetchVehicleLocation() async {
    // Get user location
    await getUserLocation();

    // Fetch vehicle location from API
    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/get_vehicle_dashboard?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        vehicleLocation = {
          'latitude': double.parse(data['data'][0]['latitude'].toString()),
          'longitude': double.parse(data['data'][0]['longitude'].toString()),
        };
        isLoading = false;
      });

      // After fetching vehicle location, draw the route
      drawRoute();
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load location');
    }
  }

  Future<void> getUserLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      userLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });
  }

  Future<void> drawRoute() async {
    if (userLocation == null || vehicleLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(userLocation!.latitude, userLocation!.longitude),
      PointLatLng(vehicleLocation!['latitude'], vehicleLocation!['longitude']),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 6,
            points: polylineCoordinates,
          ),
        );
      });
    }
  }

  Widget _buildDialogOption(String imagePath, String label,
      VoidCallback onPressed, double deviceWidth) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
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
              width: deviceWidth * 0.4,
              height: deviceWidth * 0.15,
            ),
            SizedBox(height: deviceWidth * 0.0),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Raleway',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : VehicleMap(
                  userLocation: userLocation!,
                  vehicleLocation: LatLng(vehicleLocation!['latitude'],
                      vehicleLocation!['longitude']),
                  polylines: polylines,
                ),
          Positioned(
            top: screenHeight * 0.08,
            left: screenWidth * 0.07,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  const Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Goldman',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleMap extends StatelessWidget {
  final LatLng userLocation;
  final LatLng vehicleLocation;
  final Set<Polyline> polylines;

  VehicleMap({
    required this.userLocation,
    required this.vehicleLocation,
    required this.polylines,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: userLocation,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('userLocation'),
          position: userLocation,
        ),
        Marker(
          markerId: const MarkerId('vehicleLocation'),
          position: vehicleLocation,
        ),
      },
      polylines: polylines,
      onMapCreated: (GoogleMapController controller) {
        // You can set the map controller here if needed
      },
    );
  }
}
