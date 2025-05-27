import 'package:flutter/material.dart';

class IntroP2 extends StatelessWidget {
  const IntroP2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 375.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Break language barriers by translating voicemails and text into Sign Language in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334E7B),
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 48 * scale),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/intro3');
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(20 * scale),
                  backgroundColor: const Color(0xFF334E7B),
                  elevation: 4,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 36 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
