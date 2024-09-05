import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  MapScreen({required this.sessionId, required this.vehicleId});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController; // Make mapController nullable
  late LatLng _startingLocation;
  bool _isLoading = true;
  final TextEditingController _destinationController = TextEditingController();

  final LatLng _center = const LatLng(17.366, 78.476);
  LatLng? _destination;
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  final Set<Marker> _markers = {};

  // Define the LatLngBounds for India
  final LatLngBounds _indiaBounds = LatLngBounds(
    southwest: LatLng(6.4627, 68.1097), // Southwest coordinate (approx.)
    northeast: LatLng(35.5133, 97.3954), // Northeast coordinate (approx.)
  );

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    _fetchStartingLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Apply the LatLngBounds to restrict the map
    mapController!.moveCamera(
      CameraUpdate.newLatLngBounds(_indiaBounds, 0),
    );
    if (_startingLocation != null) {
      _updateCameraPosition(_startingLocation);
      _updateOrAddMarker(_startingLocation, "Starting Location");
    }
  }

  Future<void> _fetchStartingLocation() async {
    final response = await http.get(Uri.parse(
      'http://34.93.202.185:5000/api/v1/get_vehicle_dashboard?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}',
    ));
    print('Response Body: ${response.body}'); // Debugging statement

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final longitude = double.parse(data['data'][0]['longitude']);
      final latitude = double.parse(data['data'][0]['latitude']);

      setState(() {
        _startingLocation = LatLng(latitude, longitude);
        _isLoading = false;
        if (mapController != null) {
          _updateCameraPosition(_startingLocation);
          _updateOrAddMarker(_startingLocation, "Starting Location");
        }
      });
    } else {
      throw Exception('Failed to load starting location');
    }
  }

  _updateCameraPosition(LatLng position) {
    if (mapController != null) {
      // Ensure that the camera stays within India bounds
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  _getDirections() async {
    if (_destination != null && mapController != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDIEuHp8fW56w3FpPw02icU6TtmRkKxYm4', // Replace with your Google Maps API key
        PointLatLng(_startingLocation.latitude, _startingLocation.longitude),
        PointLatLng(_destination!.latitude, _destination!.longitude),
      );

      if (result.points.isNotEmpty) {
        _polylineCoordinates.clear();
        result.points.forEach((PointLatLng point) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: _polylineCoordinates,
            width: 5,
            color: Colors.blue,
          ));
        });
      }
    }
  }

  Future<List<String>> _getPlaceSuggestions(String input) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyDIEuHp8fW56w3FpPw02icU6TtmRkKxYm4',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final suggestions = data['predictions'] as List;
      return suggestions.map((e) => e['description'] as String).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  _setDestination(String destination) async {
    try {
      var locations = await geo.locationFromAddress(destination);
      if (locations.isNotEmpty) {
        LatLng destinationLatLng =
            LatLng(locations[0].latitude, locations[0].longitude);
        setState(() {
          _destination = destinationLatLng;
          _updateOrAddMarker(_destination!, "Destination");
          _getDirections();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Destination not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding destination')),
      );
    }
  }

  _updateOrAddMarker(LatLng position, String title) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == title);
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(
            title: title,
          ),
        ),
      );
    });
  }

  Future<void> _sendLocationToApi(LatLng location) async {
    final apiUrl =
        'http://34.93.202.185:5000/api/v1/location/set_location'; // Update API URL
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'session': widget.sessionId,
      }),
    );
    print(
        'destination Location: Latitude: ${location.latitude}, Longitude: ${location.longitude}');

    if (response.statusCode == 200) {
      print('Location successfully sent to API');
    } else {
      print('Failed to send location to API');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            minMaxZoomPreference: const MinMaxZoomPreference(
                5.0, 20.0), // Optional: Restrict zoom levels
            cameraTargetBounds:
                CameraTargetBounds(_indiaBounds), // Restrict camera to India
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
                  Text(
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(170, 0, 0, 0),
                    blurRadius: 8.0,
                  ),
                ],
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 10, 10, 10),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 10, 10, 10),
                            width: 2.0,
                          ),
                        ),
                        hintText: 'Destination',
                        hintStyle: const TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color.fromARGB(255, 160, 160, 160),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.blue),
                          onPressed: () {
                            _setDestination(_destinationController.text);
                          },
                        ),
                      ),
                    ),
                    suggestionsCallback: _getPlaceSuggestions,
                    itemBuilder: (context, suggestion) {
                      return Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _destinationController.text = suggestion;
                      _setDestination(suggestion);
                    },
                    suggestionsBoxDecoration: SuggestionsBoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                      elevation: 4.0,
                      constraints: const BoxConstraints(
                        maxHeight: 400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_destination != null) {
                        _sendLocationToApi(_destination!);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            Timer(const Duration(seconds: 2), () {
                              Navigator.of(context).pop();
                            });

                            return const AlertDialog(
                              content: Text(
                                'Please select a destination first.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            );
                          },
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(73),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 9, 84, 94),
                          width: 2.0,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: const Text(
                          'Load to vehicle',
                          style: TextStyle(
                            fontFamily: 'Goldman',
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
