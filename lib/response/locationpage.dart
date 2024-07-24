import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindMyVehiclePage extends StatefulWidget {
  final double latitude;
  final double longitude;

  FindMyVehiclePage({required this.latitude, required this.longitude});

  @override
  _FindMyVehiclePageState createState() => _FindMyVehiclePageState();
}

class _FindMyVehiclePageState extends State<FindMyVehiclePage> {
  String? address;
  final String googleApiKey = 'AIzaSyBVn1idxtxfsovEZx8uUVc4NEp1pn9_FEE';
  LatLng? vehicleLocation;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    convertCoordinatesToAddress(widget.latitude, widget.longitude);
  }

  Future<void> convertCoordinatesToAddress(
      double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            address = data['results'][0]['formatted_address'];
            vehicleLocation = LatLng(longitude, latitude);
          });

          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: vehicleLocation!,
                  zoom: 14.0,
                ),
              ),
            );
          }
        } else {
          setState(() {
            address = 'No address found';
            vehicleLocation = null;
          });
        }
      } else {
        setState(() {
          address = 'Failed to fetch address';
          vehicleLocation = null;
        });
      }
    } catch (e) {
      setState(() {
        address = 'Failed to fetch address: $e';
        vehicleLocation = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find My Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            address == null
                ? Container()
                : Text('Address: $address',
                    style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: vehicleLocation == null
                  ? Container()
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: vehicleLocation!,
                        zoom: 14.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('vehicleLocation'),
                          position: vehicleLocation!,
                        ),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        // Automatically update camera position when the map is created
                        mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: vehicleLocation!,
                              zoom: 14.0,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
