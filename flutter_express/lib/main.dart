import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'page_starting.dart';
import 'global_variables.dart';
import '1_home/page_home.dart';
import '2_sign_to_text/page_sign_to_text.dart';
import '3_audio_text_to_sign/page_audio_text_to_sign.dart';
import '4_settings/page_settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return MaterialApp(
      home: StartingPageStateful(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final int setIndex;
  MainScreen({this.setIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = GlobalVariables.currentIndex;

  @override
  void initState() {
    super.initState();
    GlobalVariables.currentIndex = widget.setIndex;
  }

  late final List<Widget> _screens = [
    Home(onRefresh: _refreshData),
    SignToTextPage(),
    AudioTextToSignPage(),
    Settings(),
  ];

  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;
      _refreshData();
    });
  }

  void _refreshData() {
    setState(() {
      // Trigger a refresh in the Home widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _changeScreen,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF334E7B),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields, size: 30),
            label: 'Sign to Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hearing, size: 30),
            label: 'Audio/Text to Sign',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
