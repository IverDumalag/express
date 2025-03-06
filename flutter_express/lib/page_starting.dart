import 'package:flutter/material.dart';
import 'dart:math';

import 'page_landing.dart'; // Ensure LandingPage is defined in this file.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartingPageStateful(),
    );
  }
}

class StartingPageStateful extends StatefulWidget {
  const StartingPageStateful({Key? key}) : super(key: key);

  @override
  _StartingPageStatefulState createState() => _StartingPageStatefulState();
}

class _StartingPageStatefulState extends State<StartingPageStateful>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Stack(
        children: [
          // Add the image as a background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: CirclePainter(_controller.value),
                child: Container(),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 10.0), // Adjust the padding as needed
              child: Image.asset(
                'assets/images/expressLOGO.png', // Replace with your logo path
                width: 350, // Adjust the width as needed
                height: 350, // Adjust the height as needed
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'ex',
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Press',
                        style: TextStyle(
                            fontSize: 40,
                            color: Color(0xFF2354C7),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    width: 10), // Add some space between the text and image
                Image.asset(
                  'assets/images/bgdesignstarting.png', // Replace with your image path
                  width: 50, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 1.0),
              child: Text(
                'press to express',
                style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFF808080),
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334E7B),
                textStyle: const TextStyle(
                    fontFamily: 'Inter', fontWeight: FontWeight.bold),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 50), // Extra space added here
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double animationValue;

  CirclePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF051B4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0; // Set the stroke width to create a donut shape

    final radius = 70.0;
    final x = size.width * (0.5 + 0.5 * cos(animationValue * 2 * pi));
    final y = size.height * (0.5 + 0.5 * sin(animationValue * 2 * pi));

    canvas.drawCircle(Offset(x, y), radius, paint);

    final paint2 = Paint()
      ..color = const Color(0xFF2354C7)
      ..style = PaintingStyle.fill;

    final smallRadius = 40.0; // Smaller radius for the solid circle
    final x2 = size.width * (0.5 - 0.5 * cos(animationValue * 2 * pi));
    final y2 = size.height * (0.5 - 0.5 * sin(animationValue * 2 * pi));

    canvas.drawCircle(Offset(x2, y2), smallRadius, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
