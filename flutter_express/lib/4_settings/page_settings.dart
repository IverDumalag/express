import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Color.fromARGB(255, 50, 51, 53).withOpacity(0.08),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 80),
            children: <Widget>[
              SizedBox(height: 32),
              Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(

                      'Archive',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,

                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            foregroundColor: Color(0xFF334E7B),
                            minimumSize: Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/archive');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Archived Cards",
                                style: TextStyle(color: Color(0xFF334E7B), fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.archive, color: Color(0xFF334E7B)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Give us a feedback!',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            foregroundColor: Color(0xFF334E7B),
                            minimumSize: Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FeedbackPage()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Create a Feedback",
                                style: TextStyle(color: Color(0xFF334E7B), fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.feedback, color: Color(0xFF334E7B)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF334E7B),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Stack(
                      children: [
                        // Border layer
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              // border removed
                            ),
                          ),
                        ),
                        // Content layer clipped to border radius
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 1.0),
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Text(
                  'Others',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF334E7B),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    value: null,
                    hint: Text('Select an option'),
                    items: [
                      DropdownMenuItem(
                        value: 'privacy',
                        child: Text('Privacy Policy'),
                      ),
                      DropdownMenuItem(
                        value: 'terms',
                        child: Text('Terms & Conditions'),
                      ),
                    ],
                    onChanged: (value) {
                      // TODO: Implement navigation or dialog for each option
                      if (value == 'privacy') {
                        // Show privacy policy
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Privacy Policy'),
                            content: Text('Privacy Policy details go here.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'terms') {
                        // Show terms & conditions
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Terms & Conditions'),
                            content: Text('Terms & Conditions details go here.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF334E7B),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),

                    ),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
        ],
      ),
    );
  }
}
