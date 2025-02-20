import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'page_starting.dart';
import 'global_variables.dart';
import './sign_to_text/page_sign_to_text.dart';
import './settings/page_settings.dart';
import './home/page_home.dart';
import 'audio_text_to_sign/page_audio_text_to_sign.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return MaterialApp(
      home: StartingPageStateful(),
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _changeScreen(int index) {
    setState(() {
      GlobalVariables.currentIndex = index;
    });
  }

  late final List<Widget> _screens = [
    Home(),
    SignToTextPage(),
    AudioTextToSignPage(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: _screens[GlobalVariables.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Set the background color to white
        currentIndex: GlobalVariables.currentIndex,
        onTap: (index) {
          _changeScreen(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF334E7B), // Change color to 0xFF334E7B
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30), // Increased icon size
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields, size: 30), // Increased icon size
            label: 'Sign to Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hearing, size: 30), // Increased icon size
            label: 'Audio/Text to Sign',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30), // Increased icon size
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}