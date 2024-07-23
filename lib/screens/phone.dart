import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({super.key});

  static String verify = "";

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    countryCodeController.text = "+91"; // Set default value to "+91"
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -screenSize.width * 0.2,
            top: -screenSize.height * 0.06,
            child: Image.asset(
              'assets/images/Ellipse.png',
              width: screenSize.width * 0.8,
              height: screenSize.height * 0.3,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: screenSize.width * 0,
            top: -screenSize.height * 0.085,
            child: Image.asset(
              'assets/images/Rectangle.png',
              width: screenSize.width * 0.7,
              height: screenSize.height * 0.3,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: -screenSize.width * 0.08,
            top: -screenSize.height * 0.07,
            child: Image.asset(
              'assets/images/Rectangles.png',
              width: screenSize.width * 1,
              height: screenSize.height * 0.4,
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Phone Verification',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12), // Adding SizedBox for spacing
                  const Text(
                    'Login through your registered phone number and start your deliveries.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center, // Aligning text to center
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: countryCodeController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(), // Add border
                                labelText: 'Country Code',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Phone Number', // Add border
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10), // Add SizedBox for spacing
                    ],
                  ),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: countryCodeController.text + phoneNumberController.text,
                          verificationCompleted: (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (String verificationId, int? resendToken) {
                            MyPhone.verify = verificationId;
                            Navigator.pushNamed(context, "otp");
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                        // Navigator.pushNamed(context, "otp");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Send the Code',
                        style: TextStyle(color: Colors.white), // Set text color to white
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.09,
            left: screenSize.width * 0.345,
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 40,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
