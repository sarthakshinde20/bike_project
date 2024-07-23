import 'package:bike_project/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSVGDemo extends StatefulWidget {
  const AnimatedSVGDemo({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHome()),
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
    );
  }
}

class SnakeBorderPainter extends CustomPainter {
  final double animationValue;

  SnakeBorderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    const double borderWidth = 4.0;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Path borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(rect.width, 0)
      ..lineTo(rect.width, rect.height)
      ..lineTo(0, rect.height)
      ..close();

    final Gradient gradient = LinearGradient(
      colors: const [
        Colors.blue,
        Colors.red,
        Colors.blue,
      ],
      stops: const [
        0.0,
        0.25,
        1.0,
      ],
      transform: GradientRotation(animationValue * 2 * 3.1415927),
    );

    final Paint gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(borderPath, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
