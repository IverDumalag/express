import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
import 'package:flutter_express/0_components/popup_confirmation.dart';
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
          // Background decorative elements
    
          ListView(
            padding: EdgeInsets.only(bottom: 80),
            children: <Widget>[
              SizedBox(height: 64),
              
              // Header without background
              SizedBox(
                height: 0,
              ),
              Center(
                child: Text(
                  'Menu',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334E7B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Archive
              SectionLabel("Archive"),
              MenuButton(
                text: "Archived Cards",
                icon: Icons.archive_outlined,
                onPressed: () => Navigator.pushNamed(context, '/archive'),
              ),
              SizedBox(height: 8),

              // Feedback
              SectionLabel("Give us a feedback!"),
              MenuButton(
                text: "Create a Feedback",
                icon: Icons.feedback_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                ),
              ),
              SizedBox(height: 24),

              // FAQ
              SectionLabel("Frequently Asked Questions"),
              FAQContainer(),

              SizedBox(height: 24),
              SectionLabel("Others"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    value: null,
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF334E7B)),
                    hint: Text(
                      'Select other information',
                      style: GoogleFonts.robotoMono(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'privacy',
                        child: Row(
                          children: [
                            Icon(Icons.privacy_tip_outlined, size: 20, color: Color(0xFF334E7B)),
                            SizedBox(width: 12),
                            Text('Privacy Policy', style: GoogleFonts.robotoMono()),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'terms',
                        child: Row(
                          children: [
                            Icon(Icons.description_outlined, size: 20, color: Color(0xFF334E7B)),
                            SizedBox(width: 12),
                            Text('Terms & Conditions', style: GoogleFonts.robotoMono()),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == 'privacy') {
                        _showInfoDialog(context, 'Privacy Policy', 'Privacy Policy details go here.');
                      } else if (value == 'terms') {
                        _showInfoDialog(context, 'Terms & Conditions', 'Terms & Conditions details go here.');
                      }
                    },
                  ),
                ),
              ),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Color(0xFF334E7B), Color(0xFF4A6BA5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF334E7B).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () async {
                      final confirmed = await PopupConfirmation.show(
                        context,
                        title: "Logout",
                        message: "Are you sure you want to logout?",
                        confirmText: "Yes, logout",
                        cancelText: "Cancel",
                      );
                      
                      if (confirmed) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        UserSession.user = null;
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          "Logout",
                          style: GoogleFonts.robotoMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Color(0xFF334E7B),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: double.maxFinite,
                child: Text(
                  content, 
                  style: GoogleFonts.robotoMono(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [Color(0xFF334E7B), Color(0xFF4A6BA5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close', 
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

/// Reusable section label
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334E7B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Reusable menu button
class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const MenuButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            minimumSize: Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: GoogleFonts.robotoMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334E7B),
                ),
              ),
              Icon(icon, color: Color(0xFF4A6BA5), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// FAQ container widget
class FAQContainer extends StatelessWidget {
  const FAQContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FAQItem(
                  question: 'What is exPress?',
                  answer:
                      'exPress is a mobile and web application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion.',
                  questionFontSize: 15,
                  answerFontSize: 13,
                ),
                Divider(height: 1, color: Colors.grey[100]),
                FAQItem(
                  question: 'How does exPress work?',
                  answer:
                      'exPress works by converting sign language to text and text/audio to sign language using advanced machine learning algorithms.',
                  questionFontSize: 15,
                  answerFontSize: 13,
                ),
                Divider(height: 1, color: Colors.grey[100]),
                FAQItem(
                  question: 'How can I provide feedback?',
                  answer:
                      'You can provide feedback through the feedback section in the app menu.',
                  questionFontSize: 15,
                  answerFontSize: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}