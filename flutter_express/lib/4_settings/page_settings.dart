import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }

    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }

    setState(() {
      _cameraAccess = cameraStatus.isGranted;
      _voiceAccess = microphoneStatus.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 80), // Add padding for logout button space
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
                        color: Color(0xFF334E7B), 
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
                onChanged: (bool value) async {
                  if (value) {
                    final status = await Permission.camera.request();
                    setState(() => _cameraAccess = status.isGranted);
                  } else {
                    openAppSettings();
                  }
                  _checkPermissions();
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
                onChanged: (value) async {
                  if (value) {
                    final status = await Permission.microphone.request();
                    setState(() => _voiceAccess = status.isGranted);
                  } else {
                    openAppSettings();
                  }
                  _checkPermissions();
                },
                secondary: Icon(Icons.mic),
                activeColor: Color(0xFF334E7B),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF334E7B),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.feedback),
                  label: Text("Give Us Feedback! It Helps!"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FeedbackPage()),
                    );
                  },
                ),
              ),
              // Archive
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF334E7B),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.archive),
                  label: Text("Archive"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/archive');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'FAQs',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF334E7B),
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
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                UserSession.user = null;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
