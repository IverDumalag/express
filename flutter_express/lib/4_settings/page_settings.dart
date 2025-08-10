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
              SizedBox(height: 64), // Increased space before Menu
              Center(
                child: Text(
                  'Menu',
                  style: GoogleFonts.robotoMono(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334E7B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 20), // Space between Menu and text labels
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
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
                        color: const Color.fromARGB(255, 87, 87, 87),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)), // Add drop shadow
                            foregroundColor: MaterialStateProperty.all(Color(0xFF334E7B)),
                            minimumSize: MaterialStateProperty.all(Size(double.infinity, 70)),
                            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Color(0xFF334E7B), width: 2),
                                );
                              }
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              );
                            }),
                            elevation: MaterialStateProperty.all(6), // Increase elevation for shadow
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/archive');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Archived Cards",
                                  style: GoogleFonts.robotoMono(
                                    color: Color(0xFF334E7B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                  horizontal: 40.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Give us a feedback!',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        color: const Color.fromARGB(255, 87, 87, 87),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)), // Add drop shadow
                            foregroundColor: MaterialStateProperty.all(Color(0xFF334E7B)),
                            minimumSize: MaterialStateProperty.all(Size(double.infinity, 70)),
                            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
                              if (states.contains(MaterialState.hovered)) {
                                return RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Color(0xFF334E7B), width: 2),
                                );
                              }
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              );
                            }),
                            elevation: MaterialStateProperty.all(6), // Increase elevation for shadow
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
                              Padding(
                                padding: EdgeInsets.only(left:0),
                                child: Text(
                                  "Create a Feedback",
                                    style: GoogleFonts.robotoMono(
                         
                                    fontSize: 18,
                                    color: Color(0xFF334E7B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 87, 87, 87),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Content layer clipped to border radius
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 1.0),
                                FAQItem(
                                  question: 'What is exPress?',
                                  answer:
                                      'exPress is a mobile and web application designed to allow abled people to connect within '
                                      'deaf-mute communities seamlessly and vice-versa. With features like sign language '
                                      'to text and text/audio to sign language conversion.',
                                  questionFontSize: 20, // Example size for question
                                  answerFontSize: 16,   // Example size for answer
                                ),
                                FAQItem(
                                  question: 'How does exPress work?',
                                  answer:
                                      'exPress works by converting sign language to text and text/audio to sign language '
                                      'using advanced machine learning algorithms.',
                                  questionFontSize: 20,
                                  answerFontSize: 16,
                                ),
                                FAQItem(
                                  question: 'How can I provide feedback?',
                                  answer:
                                      'You can provide feedback through the feedback section in the app menu.',
                                  questionFontSize: 20,
                                  answerFontSize: 16,
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Others',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 87, 87, 87),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    value: null,
                    hint: Text('Select other information'),
                    items: [
                      DropdownMenuItem(
                        value: 'privacy',
                        child: Text('Privacy Policy', style: TextStyle(fontFamily: 'RobotoMono')),
                      ),
                      DropdownMenuItem(
                        value: 'terms',
                        child: Text('Terms & Conditions', style: TextStyle(fontFamily: 'RobotoMono')),
                      ),
                    ],
                    onChanged: (value) {
                      // TODO: Implement navigation or dialog for each option
                      if (value == 'privacy') {
                        // Show privacy policy
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Color(0xFF334E7B), width: 2),
                            ),
                            insetPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                            title: Text('Privacy Policy'),
                            content: Container(
                              width: 350,
                              child: Text('Privacy Policy details go here.', style: TextStyle(fontFamily: 'RobotoMono')),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close', style: TextStyle(fontFamily: 'RobotoMono')),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'terms') {
                        // Show terms & conditions
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Color(0xFF334E7B), width: 2),
                            ),
                            insetPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                            title: Text('Terms & Conditions'),
                            content: Container(
                              width: 350,
                              child: Text('Terms & Conditions details go here.', style: TextStyle(fontFamily: 'RobotoMono')),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close', style: TextStyle(fontFamily: 'RobotoMono')),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFF334E7B)),
                    shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)), // Add drop shadow
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity, 70)),
                    shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xFF334E7B), width: 2),
                        );
                      }
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      );
                    }),
                    elevation: MaterialStateProperty.all(6), // Increase elevation for shadow
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    UserSession.user = null;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  label: Text(
                    "Logout",
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
