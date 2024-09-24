import 'package:bike_project/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

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
    listenForOtp(); // Start listening for the OTP
  }

  @override
  void codeUpdated(String code) {
    setState(() {
      _otpController.text = code; // Automatically set the OTP in the controller
    });
  }

  Future<void> listenForOtp() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener(); // Stop listening for OTP
    super.dispose();
  }

  Future<void> resendOtp(String mobileNumber) async {
    if (isLoading) return; // Prevent multiple submissions
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://34.93.202.185:5000/api/v1/mobile_otp_login'), // Use your correct API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'mobile_number': mobileNumber,
        }),
      );
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debugging statement

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          _otpController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP has been resent successfully')),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend OTP')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while resending OTP')),
      );
    }
  }

  Future<void> _verifyOtp(String mobileNumber) async {
    if (isLoading) return;
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
        final name = responseData['name'] ?? '';

        if (sessionId.isNotEmpty && vehicleId.isNotEmpty) {
          await fetchDashboardData(sessionId, vehicleId);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('sessionId', sessionId);
          await prefs.setString('vehicleId', vehicleId);
          await prefs.setString('name', name);

          // Ensure you fetch and store dashboardData and responseData correctly
          await prefs.setString('dashboardData', jsonEncode(dashboardData));
          await prefs.setString('responseData', jsonEncode(responseData));

          _showAlertDialog(
              'Verified Successfully', 'assets/images/otpvalid.png', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyHome(
                  sessionId: sessionId,
                  vehicleId: vehicleId,
                  dashboardData: dashboardData,
                  responseData: responseData,
                  name: name,
                ),
              ),
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                imagePath,
                height: 55.0,
                width: 55.0,
              ),
              const SizedBox(width: 10), // Use width for horizontal spacing
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
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

    Future.delayed(const Duration(seconds: 3), () {
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
      print('Response Body: ${response.body}'); // Debugging statement
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
            right: screenWidth * 0.21,
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.85,
                height: screenHeight * 0.3,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.14,
            right: screenWidth * 0.45,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 34,
                    fontFamily: 'Goldman',
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w700,
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
                    size: screenWidth * 0.07,
                  ),
                  SizedBox(width: screenWidth * 0.005),
                  const Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.34, // Adjust as needed
            left: screenWidth * 0.07, // Adjust as needed
            right: screenWidth * 0.06, // Adjust as needed
            child: const Text(
              'Verify Your Registration',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: screenWidth * 0.07, // Adjust as needed
            right: screenWidth * 0.04, // Adjust as needed
            top: screenHeight * 0.47, // Adjust as needed

            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'We have sent an One Time Password to your mobile number ',
                    style: TextStyle(
                      fontFamily: 'Montserrat-Medium',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: formattedNumber ?? '',
                    style: const TextStyle(
                      fontFamily: 'Poppins-SemiBold',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontStyle: FontStyle
                          .italic, // Optional: Italicize the number for emphasis
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12.0,
            right: 12.0,
            top: screenHeight * 0.540, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Pinput(
                controller: _otpController,
                length: 6,
                obscureText: false,
                defaultPinTheme: PinTheme(
                  width: 45,
                  height: 45,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 50,
                  height: 50,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 45,
                  height: 45,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onCompleted: (pin) async {
                  final mobileNumber =
                      ModalRoute.of(context)?.settings.arguments as String?;
                  if (mobileNumber != null) {
                    await _verifyOtp(mobileNumber);
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.65,
            left: screenWidth * 0.01,
            right: screenWidth * 0.12,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final mobileNumber =
                      ModalRoute.of(context)?.settings.arguments as String?;
                  if (mobileNumber != null) {
                    resendOtp(mobileNumber);
                  }
                },
                child: RichText(
                  textAlign: TextAlign.start,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Didn’t received the OTP? ",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          color: Colors.black, // Style for the initial part
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: "Resend",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat-SemiBold',
                          color: Colors.black,
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
                  'Verify',
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
