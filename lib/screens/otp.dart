import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationPage extends StatefulWidget {
  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  String? formattedNumber;

  Future<void> _verifyOtp(String mobileNumber) async {
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
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final sessionId = responseData['session_id'];
        final vehicleId = responseData[
            'vehicle_id']; // Assuming the vehicle_id is in the response

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sessionId', sessionId);

        _showAlertDialog('Verified Successfully', 'assets/images/otpvalid.png',
            () {
          Navigator.pushNamed(
            context,
            'home',
            arguments: {'sessionId': sessionId, 'vehicleId': vehicleId},
          );
        });
      } else {
        print('Failed response: ${response.body}');
        _showAlertDialog('Invalid  Provided', 'assets/images/otpinvalid.png');
      }
    } catch (error) {
      print('Error occurred: $error');
      _showAlertDialog('Invalid OTP Provided', 'assets/images/otpinvalid.png');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final mobileNumber =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
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
                  // Add your resend OTP logic here
                  print('Resend OTP');
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
            top: 650.0, // Adjust the position from the bottom as needed
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
    return '+91 ${number.substring(0, 2)}******${number.substring(8)}';
  }
}
