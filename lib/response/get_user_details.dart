import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GetUserDetailsPage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  GetUserDetailsPage({required this.sessionId, required this.vehicleId});

  @override
  _GetUserDetailsPageState createState() => _GetUserDetailsPageState();
}

class _GetUserDetailsPageState extends State<GetUserDetailsPage> {
  Map<String, dynamic>? userDetails;

  Future<void> fetchUserDetails() async {
    final response = await http.get(
      Uri.parse(
          'http://34.93.202.185:5000/api/v1/get_user_details?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        userDetails = json.decode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load user details');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Center(
        child: userDetails == null
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
                      Text('User Details:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(userDetails.toString()),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
