import 'package:flutter/material.dart';
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
    return MaterialApp(
      home: StartingPage(),
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
        body: _screens[GlobalVariables.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: GlobalVariables.currentIndex,
          onTap: (index) {
            _changeScreen(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_fields),
              label: 'Sign to Text',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hearing),
              label: 'Audio/Text to Sign',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ));
  }
}
