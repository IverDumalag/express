import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_express/global_variables.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feedbackpage.dart';
import 'faq_item.dart';
import '../0_components/popup_confirmation.dart';

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

  Future<void> _handleLogout() async {
    final confirmed = await PopupConfirmation.show(
      context,
      title: "Logout Confirmation",
      message: "Are you sure you want to logout?",
      confirmText: "Logout",
      cancelText: "Cancel",
    );

    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userData');
      UserSession.user = null;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 50, 51, 53).withOpacity(0.08),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: <Widget>[
              const SizedBox(height: 64),
              Center(
                child: Text(
                  'Menu',
                  style: GoogleFonts.robotoMono(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334E7B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Archive
              SectionLabel("Archive"),
              MenuButton(
                text: "Archived Cards",
                icon: Icons.archive,
                onPressed: () => Navigator.pushNamed(context, '/archive'),
              ),

              // Feedback
              SectionLabel("Give us a feedback!"),
              MenuButton(
                text: "Create a Feedback",
                icon: Icons.feedback,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                ),
              ),

              const SizedBox(height: 16),

              // FAQ
              SectionLabel("Frequently Asked Questions"),
              const FAQContainer(),

              const SizedBox(height: 16.0),

              // Others Dropdown
              SectionLabel("Others"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    value: null,
                    hint: const Text('Select other information'),
                    items: const [
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334E7B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.robotoMono(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _handleLogout,
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
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334E7B), width: 2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        title: Text(title),
        content: SizedBox(
          width: 350,
          child: Text(content, style: const TextStyle(fontFamily: 'RobotoMono')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontFamily: 'RobotoMono')),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color.fromARGB(255, 87, 87, 87),
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
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(double.infinity, 70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334E7B),
                ),
              ),
              Icon(icon, color: const Color(0xFF334E7B)),
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
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FAQItem(
                  question: 'What is exPress?',
                  answer:
                      'exPress is a mobile and web application designed to allow abled people to connect within deaf-mute communities seamlessly and vice-versa. With features like sign language to text and text/audio to sign language conversion.',
                  questionFontSize: 20,
                  answerFontSize: 16,
                ),
                FAQItem(
                  question: 'How does exPress work?',
                  answer:
                      'exPress works by converting sign language to text and text/audio to sign language using advanced machine learning algorithms.',
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
      ),
    );
  }
}
