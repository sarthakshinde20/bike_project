import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'videoscreen.dart';

class MapScreen extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  MapScreen({required this.sessionId, required this.vehicleId});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  late LatLng _startingLocation;
  bool _isLoading = true;
  final TextEditingController _destinationController = TextEditingController();

  final LatLng _center = const LatLng(17.366, 78.476);
  LatLng? _destination;
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  final Set<Marker> _markers = {};

  final LatLngBounds _indiaBounds = LatLngBounds(
    southwest: const LatLng(6.4627, 68.1097),
    northeast: const LatLng(35.5133, 97.3954),
  );

  List<String> _favoritePlaces = [];

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    _fetchStartingLocation();
    _loadFavoritePlaces();
  }

  Future<void> _loadFavoritePlaces() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePlaces = prefs.getStringList('favoritePlaces') ?? [];
    });
  }

  Future<void> _saveFavoritePlaces() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritePlaces', _favoritePlaces);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
    print('Response Body: ${response.body}');

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
            polylineId: const PolylineId('route'),
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
          const SnackBar(content: Text('Destination not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error finding destination')),
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              VideoPlayerScreen(videoPath: 'assets/videos/success.mp4'),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              VideoPlayerScreen(videoPath: 'assets/videos/failure.mp4'),
        ),
      );
    }
  }

  void _addFavoritePlace(String place) {
    setState(() {
      // Check if the place is already in the favorite places list
      if (!_favoritePlaces.contains(place)) {
        _favoritePlaces.add(place);
        _saveFavoritePlaces(); // Save favorite places to shared_preferences
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a callback to close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(); // Close the dialog
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Added to Favorites',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            _favoritePlaces.contains(place)
                ? '$place is already in your favorites!'
                : '$place has been added to your favorites!',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  // Show dialog with favorite places
  void _showFavoritePlacesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Favorite Places',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                fontSize: 18),
            textAlign: TextAlign.start,
          ),
          content: _favoritePlaces.isNotEmpty
              ? Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        _favoritePlaces.length > 5 ? 5 : _favoritePlaces.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            _favoritePlaces[index],
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _removeFavoritePlace(_favoritePlaces[index]);
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            _setDestination(_favoritePlaces[index]);
                          },
                        ),
                      );
                    },
                  ),
                )
              : const Text('No favorite places added yet.',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'Montserrat')),
          actions: [
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeFavoritePlace(String place) {
    setState(() {
      _favoritePlaces.remove(place);
    });
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
            minMaxZoomPreference: const MinMaxZoomPreference(5.0, 20.0),
            cameraTargetBounds: CameraTargetBounds(_indiaBounds),
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
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.25,
            right: screenWidth * 0.03,
            child: IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Colors.black,
                size: screenWidth * 0.1,
              ),
              onPressed: () {
                if (_destinationController.text.isNotEmpty) {
                  _addFavoritePlace(_destinationController.text);
                } else {
                  _showFavoritePlacesDialog();
                }
              },
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
                          color: Color.fromARGB(255, 160, 160, 160),
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

                            return AlertDialog(
                              content: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Adjusts the row to its content's width
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/error.png', // Replace with your image path
                                    width: 50, // Adjust width as needed
                                    height: 50, // Adjust height as needed
                                    fit: BoxFit.cover, // Adjust fit as needed
                                  ),
                                  const SizedBox(
                                      width:
                                          16), // Space between image and text
                                  const Expanded(
                                    child: Text(
                                      'Please select a destination first.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
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
