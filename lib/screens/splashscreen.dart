import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; // Import your login page
import 'dart:convert';

class AnimatedVideoDemo extends StatefulWidget {
  const AnimatedVideoDemo({super.key});

  @override
  _AnimatedVideoDemoState createState() => _AnimatedVideoDemoState();
}

class _AnimatedVideoDemoState extends State<AnimatedVideoDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Continuously repeat the animation

    // Initialize the video player controller
    _videoController = VideoPlayerController.asset('assets/videos/logo.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoController.setLooping(true);
          _videoController.play();
        });
      });

    // Check for existing session and navigate accordingly
    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('sessionId');
      final vehicleId = prefs.getString('vehicleId');
      final name = prefs.getString('name');

      final dashboardDataJson = prefs.getString('dashboardData');
      final responseDataJson = prefs.getString('responseData');

      final dashboardData = dashboardDataJson != null
          ? Map<String, dynamic>.from(jsonDecode(dashboardDataJson))
          : null;
      final responseData = responseDataJson != null
          ? Map<String, dynamic>.from(jsonDecode(responseDataJson))
          : null;

      if (sessionId != null &&
          vehicleId != null &&
          name != null &&
          dashboardData != null &&
          responseData != null) {
        // Navigate to the home page with all required arguments
        Navigator.pushReplacementNamed(
          context,
          'MyHome',
          arguments: {
            'sessionId': sessionId,
            'vehicleId': vehicleId,
            'name': name,
            'dashboardData': dashboardData,
            'responseData': responseData,
          },
        );
      } else {
        // Navigate to the login page if no session or incomplete data found
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Properly dispose the animation controller
    _videoController.dispose(); // Properly dispose the video player controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF000000),
        child: Center(
          child: _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
