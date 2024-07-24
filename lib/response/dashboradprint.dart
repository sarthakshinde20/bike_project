import 'package:flutter/material.dart';

class DashPrintPage extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;

  DashPrintPage({required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth * 0.5;

        return Align(
          alignment: Alignment.centerLeft,
          child: Transform.rotate(
            angle: 45 * (3.1415927 / 180),
            child: Container(
              width: size * 0.83,
              height: size * 0.83,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(86.62 * (3.1415927 / 90)),
                  stops: [0.2505, 0.7943, 1.2565, 1.658],
                  colors: [
                    Color(0xFF09545E),
                    Color(0xFF0C7785),
                    Color.fromRGBO(9, 84, 94, 0.517708),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.175),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -90 * (3.1415927 / 180),
                  child: Container(
                    width: size * 0.7,
                    height: size * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size * 0.125),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: 90 * (3.1415927 / 90),
                        child: Container(
                          width: size * 0.6,
                          height: size * 0.6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              transform:
                                  GradientRotation(90.3 * (3.1415927 / 90)),
                              stops: [0.1376, 0.5174, 0.8403, 1.1206],
                              colors: [
                                Color(0xFF09545E),
                                Color(0xFF0C7785),
                                Color.fromRGBO(9, 84, 94, 0.517708),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(size * 0.125),
                          ),
                          child: Center(
                            child: Text(
                              dashboardData != null &&
                                      dashboardData!['data'] != null
                                  ? '${dashboardData!['data'][0]['battery_percentage']}%'
                                  : 'N/A',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
