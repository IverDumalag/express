import 'package:flutter/material.dart';
import 'feedbackpage.dart';
import 'faq_item.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _cameraAccess = false;
  bool _voiceAccess = false;
  bool _soundEffects = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Allow EXPRESS to access your camera and microphone..',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(
              'Access Camera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _cameraAccess,
            onChanged: (bool value) {
              setState(() {
                _cameraAccess = value;
              });
            },
            secondary: Icon(Icons.camera_alt),
            activeColor: Color(0xFF334E7B),
          ),
          SwitchListTile(
            title: Text(
              'Access Microphone',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _voiceAccess,
            onChanged: (bool value) {
              setState(() {
                _voiceAccess = value;
              });
            },
            secondary: Icon(Icons.mic),
            activeColor: Color(0xFF334E7B),
          ),
          SwitchListTile(
            title: Text(
              'Sound Effects',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _soundEffects,
            onChanged: (bool value) {
              setState(() {
                _soundEffects = value;
              });
            },
            secondary: Icon(
              Icons.surround_sound,
            ),
            activeColor: Color(0xFF334E7B),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Give us some feedback',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text(
              'Feedback',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF334E7B),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'FAQs',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search about exPress',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          FAQItem(
            question: 'What is exPress?',
            answer:
                'exPress is a mobile application designed to allow abled people to connect within '
                'deaf-mute communities seamlessly and vice-versa. With features like sign language '
                'to text and text/audio to sign language conversion.',
          ),
          FAQItem(
            question: 'How does exPress work?',
            answer:
                'exPress works by converting sign language to text and text/audio to sign language '
                'using advanced machine learning algorithms.',
          ),
          FAQItem(
            question: 'How can I provide feedback?',
            answer:
                'You can provide feedback through the feedback section in the app settings or by '
                'contacting our support team.',
          ),
        ],
      ),
    );
  }
}
