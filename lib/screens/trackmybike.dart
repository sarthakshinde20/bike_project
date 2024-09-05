import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  bool isLoading = true;
  final String googleApiKey = 'AIzaSyDIEuHp8fW56w3FpPw02icU6TtmRkKxYm4';

  @override
  void initState() {
    super.initState();
    fetchVehicleLocation();
  }

  Future<void> fetchVehicleLocation() async {
    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/get_vehicle_dashboard?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );
    print('Response Body: ${response.body}'); // Debugging statement
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        vehicleLocation = {
          'latitude': double.parse(data['data'][0]['latitude'].toString()),
          'longitude': double.parse(data['data'][0]['longitude'].toString()),
        };
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load location');
    }
  }

  Future<void> turnOnLights() async {
    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/vehicle/find_my_vehicle?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Lights turned on: ${data['message']}');
    } else {
      print('Failed to turn on lights');
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
              width:
                  deviceWidth * 0.4, // Adjust the size of the image as needed
              height:
                  deviceWidth * 0.15, // Adjust the size of the image as needed
            ),
            SizedBox(
                height:
                    deviceWidth * 0.0), // Add spacing between image and text
            Text(
              label,
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
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
              : vehicleLocation != null
                  ? VehicleMap(
                      latitude: vehicleLocation!['latitude'],
                      longitude: vehicleLocation!['longitude'],
                    )
                  : const Center(child: Text('Location not found')),
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
          Positioned(
            bottom: screenHeight * 0.15,
            right: screenWidth * 0.02,
            height: 55,
            width: 55,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
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
                                    'assets/images/horn_light.png',
                                    'Honk & Turn On Lights',
                                    () async {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      await turnOnLights(); // Call the second API
                                    },
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
                                      width: 120,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 9, 84, 94),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 9, 84, 94),
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
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
              tooltip: 'Find Bike',
              child: Image.asset(
                'assets/images/find.png',
                color: Colors.black, // Replace with your image path
                width: 45.0, // Set the desired width
                height: 45.0, // Set the desired height
              ),
            ),
          )
        ],
      ),
    );
  }
}

class VehicleMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  VehicleMap({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final LatLng vehicleLocation = LatLng(latitude, longitude);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: vehicleLocation,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('vehicleLocation'),
          position: vehicleLocation,
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        // You can set the map controller here if needed
      },
    );
  }
}
