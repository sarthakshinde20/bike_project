import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class OtpVerificationPage extends StatefulWidget {
  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? dashboardData;

  void _verifyOtp(String mobileNumber) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://34.93.202.185:5000/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'mobile_number': mobileNumber,
          'otp_code': _otpController.text,
        }),
      );

      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debugging statement

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final sessionId = responseBody['session_id'] ?? '';
        final vehicleId = responseBody['vehicles'] != null &&
                responseBody['vehicles'].isNotEmpty
            ? responseBody['vehicles'][0]['vehicle_id'] ?? ''
            : '';

        if (sessionId.isNotEmpty && vehicleId.isNotEmpty) {
          // Fetch dashboard data and navigate to MyHome with all required data
          await fetchDashboardData(sessionId, vehicleId);

          if (dashboardData != null) {
            Navigator.pushReplacementNamed(
              context,
              'MyHome',
              arguments: {
                'sessionId': sessionId,
                'vehicleId': vehicleId,
                'dashboardData': dashboardData,
              },
            );
          } else {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to fetch dashboard data')),
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid session or vehicle ID')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed response: ${response.body}'); // Debugging statement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error occurred: $error'); // Debugging statement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> fetchDashboardData(String sessionId, String vehicleId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://34.93.202.185:5000/api/v1/get_vehicle_dashboard?vehicle_id=$vehicleId&session=$sessionId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load dashboard data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load dashboard data')),
        );
      }
    } on SocketException catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Network error: $e');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileNumber =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(labelText: 'OTP Code'),
                  ),
                  ElevatedButton(
                    onPressed: () => _verifyOtp(mobileNumber),
                    child: const Text('Verify OTP'),
                  ),
                ],
              ),
      ),
    );
  }
}
