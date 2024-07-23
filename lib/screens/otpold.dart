import 'package:bike_project/screens/phone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

class Myotp extends StatefulWidget {
  const Myotp({Key? key});

  @override
  State<Myotp> createState() => _MyotpState();
}

class _MyotpState extends State<Myotp> with CodeAutoFill {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();

  String? _code;

  @override
  void codeUpdated() {
    setState(() {
      _otpController.text = code ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            left: -screenSize.width * 0.2,
            top: -screenSize.height * 0.02,
            child: Image.asset(
              'assets/images/Ellipse.png',
              width: screenSize.width * 0.8,
              height: screenSize.height * 0.3,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: -screenSize.width * 0.08,
            top: -screenSize.height * 0.1,
            child: Image.asset(
              'assets/images/Rectangles.png',
              width: screenSize.width * 1,
              height: screenSize.height * 0.4,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: screenSize.width * 0,
            top: -screenSize.height * 0.21,
            child: Image.asset(
              'assets/images/Rectangle.png',
              width: screenSize.width * 1,
              height: screenSize.height * 0.5,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Phone Verification',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12), // Adding SizedBox for spacing
                const Text(
                  'We have sent One Time Password (OTP) to your mobile number.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center, // Aligning text to center
                ),
                const SizedBox(height: 20),
                Pinput(
                  length: 6,
                  showCursor: true,
                  controller: _otpController,
                  onChanged: (value) {
                    _code = value;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: MyPhone.verify, smsCode: _code!);

                        // Sign the user in (or link) with the credential
                        await auth.signInWithCredential(credential);
                        Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
                      } catch (e) {
                        print('Wrong OTP');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Verify Phone Number',
                      style: TextStyle(color: Colors.white), // Set text color to white
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenSize.height * 0.09,
            left: screenSize.width * 0.345,
            child: const Text(
              'Verify',
              style: TextStyle(
                fontSize: 40,
                color: Color.fromARGB(255, 226, 225, 225),
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
