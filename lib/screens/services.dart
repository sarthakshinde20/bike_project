import 'package:bike_project/screens/home.dart';
import 'package:flutter/material.dart';

class servicesModel {
  void dispose() {}
}

class servicesPage extends StatefulWidget {
  const servicesPage({Key? key}) : super(key: key);

  @override
  _servicesPageState createState() => _servicesPageState();
}

class _servicesPageState extends State<servicesPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      body: Stack(children: [
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
            right: screenWidth * 0.25, // 35% of screen width
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Services',
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
          alignment: const AlignmentDirectional(0, 0.95),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyHome()),
              );
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
      ]),
    );
  }
}
