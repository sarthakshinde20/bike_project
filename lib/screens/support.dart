import 'package:bike_project/screens/home.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      body: Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(-2, -0.9),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.85, // 90% of screen width
                height: screenHeight * 0.3, // 30% of screen height
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.155, // 15% of screen height
              bottom: screenHeight * 0.025, // 2.5% of screen height
              right: screenWidth * 0.3, // 35% of screen width
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Support',
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
          Align(
            alignment: const AlignmentDirectional(0, 0.95),
            child: GestureDetector(
              onTap: () {
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.14,
                height: MediaQuery.of(context).size.width * 0.14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/home.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, -0.50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 70, 25, 30),
              child: MediaQuery.of(context).size.width > 600
                  ? const Text(
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 34,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox(
                      width: 200, // Set a width to control line breaks
                      child: Text(
                        'Hello, How can we help you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true, // Allow text to wrap to the next line
                      ),
                    ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, -0.15),
            child: Container(
              margin: MediaQuery.of(context).size.width > 600
                  ? const EdgeInsets.fromLTRB(60, 70, 60, 40) // Larger screens
                  : const EdgeInsets.fromLTRB(
                      35, 50, 35, 25), // Smaller screens
              child: TextFormField(
                maxLines: MediaQuery.of(context).size.width > 600 ? 5 : 3,
                decoration: InputDecoration(
                  hintText:
                      'About', // Changed from labelText to hintText for placeholder
                  hintStyle: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(121, 121, 121,
                          121) // Increased text size for the placeholder
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 66, 62, 62),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 66, 62, 62),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color:
                        Colors.black // Increased text size for the input text
                    ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              height: MediaQuery.of(context).size.height *
                  0.07, // 7% of screen height
              child: TextButton(
                onPressed: () {
                  // Add your submit logic here
                },
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.zero, // Remove padding around the button text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(73), // Rounded corners
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    // Solid white color
                    border: Border.all(
                      color: const Color.fromARGB(255, 9, 84, 94),
                      width: 2.0,
                    ),
                    borderRadius:
                        BorderRadius.circular(1000), // Rounded corners
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Submit Issue',
                      style: TextStyle(
                        fontFamily: 'Goldman',
                        color: Color.fromARGB(
                            255, 0, 0, 0), // Text color of the button
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.35),
            child: Divider(
              height: 0,
              thickness: 2,
              indent: MediaQuery.of(context).size.width *
                  0.1, // Adjusted indent based on screen width
              color: Colors.black,
              endIndent: MediaQuery.of(context).size.width *
                  0.6, // Adjusted endIndent based on screen width
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.35),
            child: Divider(
              height: 0,
              thickness: 2,
              indent: MediaQuery.of(context).size.width *
                  0.6, // Adjust indent for larger screens
              color: Colors.black,
              endIndent: MediaQuery.of(context).size.width > 600
                  ? 20
                  : 35, // Adjust endIndent for larger screens
            ),
          ),
          Align(
            alignment: MediaQuery.of(context).size.width > 600
                ? const AlignmentDirectional(
                    0, 0.5) // Adjusted alignment for larger screens
                : const AlignmentDirectional(
                    0, 0.35), // Default alignment for smaller screens
            child: Text(
              'OR',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w500,
                fontSize: MediaQuery.of(context).size.width > 600
                    ? 18
                    : 14, // Adjusted font size based on screen width
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0.55),
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              height: MediaQuery.of(context).size.height *
                  0.07, // 7% of screen height
              child: TextButton(
                onPressed: () {
                  // Add your submit logic here
                },
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.zero, // Remove padding around the button text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(73), // Rounded corners
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 9, 84, 94),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(
                        1000), // Extremely rounded corners
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12), // Padding for icon and text spacing
                    child: const Row(
                      mainAxisSize: MainAxisSize
                          .min, // Use the minimum space that content needs
                      children: [
                        Icon(Icons.phone,
                            color: Color.fromARGB(255, 1, 1, 1)), // Phone icon
                        SizedBox(width: 30), // Space between icon and text
                        Text(
                          'Customer Care',
                          style: TextStyle(
                            fontFamily: 'Goldman',
                            color: Color.fromARGB(
                                255, 0, 0, 0), // Text color of the button
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
