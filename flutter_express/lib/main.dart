import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_express/4_settings/archived_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_landing.dart';
import 'global_variables.dart';
import '1_home/page_home.dart';
import '2_sign_to_text/page_sign_to_text.dart';
import '3_audio_text_to_sign/page_audio_text_to_sign.dart';
import '4_settings/page_settings.dart';
import 'intro_p1.dart';
import 'intro_p2.dart';
import 'intro_p3.dart';
import 'login.dart';
import 'register.dart';
import '5_profile/page_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.robotoMono().fontFamily,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: InitialRouteDecider(),
      routes: {
        '/intro1': (context) => IntroP1(),
        '/intro2': (context) => IntroP2(),
        '/intro3': (context) => IntroP3(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/landing': (context) => LandingPage(),
        '/main': (context) => MainScreen(),
        '/profile': (context) => PageProfile(),
        '/archive': (context) => ArchivedCardsPage(),
      },
    );
  }
}

class InitialRouteDecider extends StatefulWidget {
  @override
  State<InitialRouteDecider> createState() => _InitialRouteDeciderState();
}

class _InitialRouteDeciderState extends State<InitialRouteDecider> {
  @override
  void initState() {
    super.initState();
    _checkIntro();
  }

  Future<void> _checkIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('seenIntro') ?? false;
    if (seenIntro) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/intro1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
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
    AudioTextToSignPage(),
    SignToTextPage(),
    Settings(),
    PageProfile(),
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
            icon: Icon(Icons.hearing, size: 30),
            label: 'Audio/Text to Sign',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields, size: 30),
            label: 'Sign to Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 30),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}