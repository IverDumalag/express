import 'package:flutter/material.dart';
import '../0_components/help_widget.dart';

class SignToTextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            color: Colors.white,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF334E7B), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.camera_alt,
                          size: 50, color: Colors.black54),
                      onPressed: () {
                        // Add your onPressed code here to enable the camera
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF334E7B), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Translation Output',
                      style: TextStyle(fontSize: 24, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Use the customizable HelpIconWidget here
          Positioned(
            top: 16,
            right: 16,
            child: HelpIconWidget(
              helpTitle: 'How to Use',
              helpText: '1. Tap the camera icon to enable your camera.\n'
                  '2. Position your hand gestures within the camera view.\n'
                  '3. The translation of your sign gestures will appear in the output container below.',
            ),
          ),
        ],
      ),
    );
  }
}
