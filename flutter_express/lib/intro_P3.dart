import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroP3 extends StatelessWidget {
  const IntroP3({Key? key}) : super(key: key);

  Future<void> _finishIntro(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenIntro', true);
    Navigator.pushReplacementNamed(context, '/login');
  }

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
                'Master signs with data-driven flashcards for easy and effective learning.',
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
                onPressed: () => _finishIntro(context),
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
