import 'dart:convert';

import 'package:bike_project/response/dashboardpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  HomePage({required this.sessionId, required this.vehicleId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final storedSessionId = prefs.getString('sessionId');

    if (storedSessionId == null || storedSessionId != widget.sessionId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session expired, please login again.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://34.93.202.185:5000/logout'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'session': widget.sessionId,
        }),
      );

      if (response.statusCode == 200) {
        await prefs.remove('sessionId'); // Clear stored session ID
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout successful')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout')),
        );
      }
    } catch (e) {
      print('Error occurred during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Session ID: ${widget.sessionId}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Vehicle ID: ${widget.vehicleId}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Dashboard Data:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: DashboardPage(
              sessionId: widget.sessionId,
              vehicleId: widget.vehicleId,
            ),
          ),
        ],
      ),
    );
  }
}
