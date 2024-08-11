import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool isLoading = false;
  String? formattedNumber;
  Map<String, dynamic>? dashboardData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mobileNumber =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (mobileNumber != null) {
        setState(() {
          formattedNumber = formatMobileNumber(mobileNumber);
        });
      }
    });
  }

  Future<void> _verifyOtp(String mobileNumber) async {
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
        final responseData = jsonDecode(response.body);
        final sessionId = responseData['session_id'] ?? '';
        final vehicleId = responseData['vehicles'] != null &&
                responseData['vehicles'].isNotEmpty
            ? responseData['vehicles'][0]['vehicle_id'] ?? ''
            : '';

        if (sessionId.isNotEmpty && vehicleId.isNotEmpty) {
          await fetchDashboardData(sessionId, vehicleId);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('sessionId', sessionId);
          await prefs.setString('vehicleId', vehicleId);
          // Ensure you fetch and store dashboardData and responseData correctly
          await prefs.setString('dashboardData', jsonEncode(dashboardData));
          await prefs.setString('responseData', jsonEncode(responseData));

          _showAlertDialog(
              'Verified Successfully', 'assets/images/otpvalid.png', () {
            Navigator.pushReplacementNamed(
              context,
              'MyHome',
              arguments: {
                'sessionId': sessionId,
                'vehicleId': vehicleId,
                'dashboardData': dashboardData,
                'responseData': responseData,
              },
            );
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showAlertDialog(
            'Invalid OTP Provided',
            'assets/images/otpinvalid.png',
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showAlertDialog('Invalid OTP', 'assets/images/otpinvalid.png');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showAlertDialog('An error occurred', 'assets/images/otpinvalid.png');
    }
  }

  void _showAlertDialog(String message, String imagePath,
      [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                imagePath,
                height: 50.0,
                width: 50.0,
              ),
              const SizedBox(height: 20), // Use width for horizontal spacing
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      if (onOk != null) {
        onOk();
      }
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load dashboard data')),
        );
      }
    } on SocketException {
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileNumber =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.022,
            left: screenWidth * 0.01,
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.9,
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            right: screenWidth * 0.45,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Goldman',
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 3.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(119, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.272,
            left: screenWidth * 0.05,
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
                      fontSize: screenWidth * 0.045, // Adjust text size
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.32, // Adjust as needed
            left: screenWidth * 0.045, // Adjust as needed
            right: screenWidth * 0.045, // Adjust as needed
            child: const Text(
              'Verify Your Registration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 10.0, // Adjust as needed
            right: 10.0, // Adjust as needed
            top: screenHeight * 0.38, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text:
                          'We have sent a One Time Password to your mobile number ',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: formattedNumber ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontStyle: FontStyle
                            .italic, // Optional: Italicize the number for emphasis
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            top: screenHeight * 0.47, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Pinput(
                controller: _otpController,
                length: 6,
                obscureText: false,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 50,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 50,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
                onCompleted: (value) {
                  print("Completed: $value");
                },
                onChanged: (value) {
                  print("Current Value: $value");
                },
              ),
            ),
          ),
          Positioned(
            top: screenHeight *
                0.58, // Adjust the position from the bottom as needed
            left: screenWidth * 0.1, // Center horizontally or adjust as needed
            right: screenWidth * 0.1, // Center horizontally or adjust as needed
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Didn't receive the OTP? ",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Raleway',
                          color: Colors.black, // Style for the initial part
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: "Resend",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Raleway',
                          color: Color.fromARGB(
                              255, 0, 0, 0), // Style for the "Resend" part
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration
                              .underline, // Optional: Underline the text
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight *
                0.83, // Adjust the position from the bottom as needed
            left: 16.0,
            right: 16.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _verifyOtp(mobileNumber),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50), // Width and Height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000), // Border radius
                  ),
                  side: const BorderSide(
                      width: 2.0, // Border width
                      color: Color.fromARGB(255, 9, 84, 94) // Border color
                      ),
                ),
                child: const Text(
                  'Verify OTP',
                  style: TextStyle(
                      fontFamily: 'Goldman',
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String formatMobileNumber(String number) {
    return '${number.substring(0, 5)}******${number.substring(10)}';
  }
}
