import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final String _countryCode = '+91';

  @override
  void initState() {
    super.initState();
    _mobileNumberController.text = _countryCode; // Set default country code
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _sendOtp() async {
    final mobileNumber = _mobileNumberController.text;
    final response = await http.post(
      Uri.parse('http://34.93.202.185:5000/api/v1/mobile_otp_login'),
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
      try {
        final responseBody = jsonDecode(response.body);

        if (responseBody['message'] == 'success' &&
            responseBody['status'] == 200) {
          Navigator.pushNamed(
            context,
            'otp',
            arguments: mobileNumber,
          );
        } else {
          _showErrorDialog(
              'You cannot login as your mobile number is not registered with it.');
        }
      } catch (e) {
        _showErrorDialog('Error parsing response');
      }
    } else {
      _showErrorDialog('Failed to send OTP');
    }
  }

  void _showErrorDialog(String message, {VoidCallback? onOK}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              fontFamily: 'Raleway',
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      if (onOK != null) {
        onOK();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(-2, -0.9),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.9, // 90% of screen width
                height: screenHeight * 0.3, // 30% of screen height
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.155, // 15% of screen height
              bottom: screenHeight * 0.025, // 2.5% of screen height
              right: screenWidth * 0.18, // 35% of screen width
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
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
          Align(
            alignment: const AlignmentDirectional(0, -0.3),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.065, // 6% of screen width
              ),
              child: const Text(
                'Login through your registered ph. no and start your rides.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-1, -0.13),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.065, // 5% of screen width
                vertical: screenHeight * 0.02, // 2% of screen height
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Mobile Number',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.02),
            child: Padding(
              padding: EdgeInsets.all(
                screenWidth * 0.065, // 6.5% of screen width for padding
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height:
                          screenHeight * 0.02, // 2% of screen height for space
                    ),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth *
                              0.04), // 4% of screen width for border radius
                        ),
                        prefixStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        errorText:
                            _validateMobileNumber(), // Show error message if validation fails
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                            13), // Limit input to 13 characters
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a mobile number';
                        }
                        if (value.length < 13) {
                          return 'Mobile number must be 10 digits with country code';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.8),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  SizedBox(
                    width: screenWidth * 0.85, // 85% of screen width
                    height: screenHeight * 0.07, // 7% of screen height
                    child: ElevatedButton(
                      onPressed: _sendOtp,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              screenWidth * 0.1), // 10% of screen width
                          side: BorderSide(
                            color: const Color.fromARGB(255, 9, 84,
                                94), // Set your desired border color
                            width: screenWidth * 0.005, // 0.5% of screen width
                          ),
                        ),
                      ),
                      child: Text(
                        'Send OTP',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Goldman',
                          fontSize: screenWidth * 0.05, // 5% of screen width
                          fontWeight: FontWeight.w400,
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

  String? _validateMobileNumber() {
    final value = _mobileNumberController.text;
    if (value.length < 13) {
      return 'Mobile number must be 10 digits';
    }
    return null; // No error
  }
}
