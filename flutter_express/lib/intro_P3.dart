import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroP3 extends StatefulWidget {
  const IntroP3({Key? key}) : super(key: key);

  @override
  State<IntroP3> createState() => _IntroP3State();
}

class _IntroP3State extends State<IntroP3> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFF334E7B),
              Color(0xFF6C88C4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Image.asset(
                          'assets/images/third.png',
                          width: 280 * scale,
                          height: 280 * scale,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 32 * scale),
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Text(
                        'Connect inclusively using intuitive gesture-based interactions for seamless communication.',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Single Button Navigates to Login
              Positioned(
                bottom: 60 * scale,
                right: 32 * scale,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(20 * scale),
                    backgroundColor: Colors.white,
                    elevation: 4,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: const Color(0xFF334E7B),
                    size: 36 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
