import 'package:flutter/material.dart';
import 'main.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _descriptions = [
    'exPress is a mobile application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion',
    'exPress is a mobile application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion.',
    // Add more descriptions as needed
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20 * _descriptions.length), // Total duration for all texts
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method that builds a RichText with colored "exPress"
  RichText buildDescription(String text) {
    // Split text by "exPress"
    final parts = text.split('exPress');
    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      // Add grey text span for the part before "exPress"
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i],
          style: TextStyle(color: Color(0xFFBEBEBE)),
        ));
      }
      // If not the last part, add the colored "exPress"
      if (i != parts.length - 1) {
        spans.add(TextSpan(
          text: 'exPress',
          style: TextStyle(
            color: Color(0xFF2354C7),
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'Inter',
        ),
        children: spans,
      ),
      textAlign: TextAlign.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double progress = _controller.value * _descriptions.length;
              int currentIndex = progress.floor() % _descriptions.length;
              double position = progress - currentIndex;
              int nextIndex = (currentIndex + 1) % _descriptions.length;

              return Stack(
                children: [
                  // Current Text using RichText
                  Positioned(
                    top: position * MediaQuery.of(context).size.height,
                    left: 16.0,
                    right: 16.0,
                    child: buildDescription(_descriptions[currentIndex]),
                  ),
                  // Next Text using RichText
                  Positioned(
                    top: (position - 1.0) * MediaQuery.of(context).size.height,
                    left: 16.0,
                    right: 16.0,
                    child: buildDescription(_descriptions[nextIndex]),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'This is your Starting Point.',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                GestureDetector(
                  onTapDown: (_) {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      gradient: LinearGradient(
                        colors: [Color(0xFF334E7B), Color(0xFF1A2A47)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: Offset(4, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: -5,
                          offset: Offset(-4, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: Size(200, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      child: const Text(
                        'Press to Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
