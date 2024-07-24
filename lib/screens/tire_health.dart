import 'package:bike_project/screens/home.dart';
import 'package:flutter/material.dart';

class TireHealthModel {
  void dispose() {}
}

class TireHealthPage extends StatefulWidget {
  const TireHealthPage({Key? key}) : super(key: key);

  @override
  _TireHealthPageState createState() => _TireHealthPageState();
}

class _TireHealthPageState extends State<TireHealthPage> {
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
                'Tyre Health',
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
                MaterialPageRoute(builder: (context) => MyHome()),
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
        Align(
          alignment: const AlignmentDirectional(0.04, -0.2),
          child: GestureDetector(
            child: Image.asset(
              'assets/images/servicesbike.png',
              width: MediaQuery.of(context).size.width *
                  0.7, // 60% of screen width
              height: MediaQuery.of(context).size.height *
                  0.25, // 25% of screen height
              fit: BoxFit.cover,
            ),
          ),
        ),
      ]),
    );
  }
}
