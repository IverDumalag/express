import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroP2 extends StatefulWidget {
  const IntroP2({Key? key}) : super(key: key);

  @override
  _IntroP2State createState() => _IntroP2State();
}

class _IntroP2State extends State<IntroP2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
              Colors.white,
              Color(0xFFE8ECF7),
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
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Image.asset(
                            'assets/images/second.png',
                            width: 260 * scale,
                            height: 260 * scale,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32 * scale),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Break language barriers by translating voicemails and text into Sign Language in real time.',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(
                            fontSize: 28 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334E7B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40 * scale,
                right: 32 * scale,
                child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
