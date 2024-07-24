import 'package:bike_project/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSVGDemo extends StatefulWidget {
  const AnimatedSVGDemo({super.key});

  @override
  _AnimatedSVGDemoState createState() => _AnimatedSVGDemoState();
}

class _AnimatedSVGDemoState extends State<AnimatedSVGDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Continuously repeat the animation

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {
          // Trigger a rebuild whenever the animation value changes
        });
      });

    // Add a delay before navigating to the login page
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Properly dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding to create a gap
          child: CustomPaint(
            painter: SnakeBorderPainter(_animation.value),
            child: Padding(
              padding:
                  const EdgeInsets.all(10.0), // Additional padding to the child
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white,
                      Colors.white.withOpacity(0)
                    ],
                    stops: [
                      _animation.value - 0.3,
                      _animation.value,
                      _animation.value + 0.3
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 28, // Adjust to your SVG's dimensions
                  height: 28,
                  // ignore: deprecated_member_use
                  color: const Color.fromARGB(255, 0, 0, 0),
                  // ignore: deprecated_member_use
                  colorBlendMode: BlendMode.srcIn, // Apply the color to the SVG
                ), // Use srcATop to blend the shader and the image properly
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SnakeBorderPainter extends CustomPainter {
  final double animationValue;

  SnakeBorderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    const double borderWidth = 4.0;
    const double borderRadius = 8.0; // Adjust the border radius as needed

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    final Path borderPath = Path()..addRRect(rrect);

    final Gradient gradient = LinearGradient(
      colors: const [
        Color.fromARGB(255, 57, 255, 20),
        Color.fromARGB(255, 91, 205, 71),
        Color.fromARGB(255, 57, 255, 20),
      ],
      stops: const [
        0.0,
        0.25,
        1.0,
      ],
      transform: GradientRotation(animationValue * 2 * 3.1415927),
    );

    final Paint gradientPaint = Paint()
      ..shader = gradient.createShader(rrect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(borderPath, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
