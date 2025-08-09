import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../0_components/help_widget.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _descriptions = [
    'exPress is a mobile application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion',
    'exPress is a mobile application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion.',
  ];

  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _controller = AnimationController(
      duration: Duration(seconds: 20 * _descriptions.length),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Compute a scale factor based on a base width (e.g., 375 pixels for medium screens)
  double _scaleFactor(BuildContext context) {
    final baseWidth = 375.0;
    return MediaQuery.of(context).size.width / baseWidth;
  }

  // Helper method that builds a RichText with colored "exPress"
  RichText buildDescription(String text, double scale) {
    final parts = text.split('exPress');
    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              color: Color(0xFFBEBEBE),
              fontSize: 36 * scale,
              fontFamily: 'RobotoMono',
            ),
          ),
        );
      }
      if (i != parts.length - 1) {
        spans.add(
          TextSpan(
            text: 'exPress',
            style: TextStyle(
              color: Color(0xFF2354C7),
              fontWeight: FontWeight.bold,
              fontSize: 36 * scale,
              fontFamily: 'RobotoMono',
            ),
          ),
        );
      }
    }
    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.right,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = _scaleFactor(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
                  // Current Text using RichText (bottom to top)
                  Positioned(
                    bottom: position * size.height,
                    left: 16 * scale,
                    right: 16 * scale,
                    child: buildDescription(_descriptions[currentIndex], scale),
                  ),
                  // Next Text using RichText (bottom to top)
                  Positioned(
                    bottom: (position - 1.0) * size.height,
                    left: 16 * scale,
                    right: 16 * scale,
                    child: buildDescription(_descriptions[nextIndex], scale),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Text(
                '',
                style: TextStyle(
                  fontSize: 45 * scale,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'RobotoMono',
                  letterSpacing: -1 * scale,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20 * scale),
                GestureDetector(
                  onTapDown: (_) {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60 * scale),
                      gradient: LinearGradient(
                        colors: [Color(0xFF334E7B), Color(0xFF1A2A47)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20 * scale,
                          spreadRadius: 2 * scale,
                          offset: Offset(4 * scale, 6 * scale),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10 * scale,
                          spreadRadius: -5 * scale,
                          offset: Offset(-4 * scale, -4 * scale),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final audioPlayer = AudioPlayer();

                        try {
                          await audioPlayer.play(
                            AssetSource('sounds/button_pressed.mp3'),
                          );
                        } catch (e) {
                          print("Error playing sound: $e");
                        }

                        if (mounted) {
                          Navigator.pushNamed(context, '/main');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: Size(200 * scale, 60 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60 * scale),
                        ),
                      ),
                      child: Text(
                        'Press to Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16 * scale,
            right: 16 * scale,
            child: HelpIconWidget(
              helpTitle:
                  'exPress: Vision-Enabled TensorFlow App For Deaf and Abled Individuals',
              helpText:
                  'A Capstone Project submitted to the Faculty of the\n'
                  'National University College of Computing and Information Technologies\n'
                  'in Partial Fulfillment of the requirements for the Degree of\n'
                  'Bachelor of Science in Information Technology\n\n'
                  'Researchers and Developers:\n\n'
                  'Dumalag, Iver Marl\n'
                  'Garcia, Alyssa Umiko\n'
                  'Ross, Angel Aisha',
            ),
          ),
        ],
      ),
    );
  }
}
