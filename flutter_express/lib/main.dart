import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_express/4_settings/archived_cards.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: SplashScreen(), // Changed to splash screen
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

// New splash screen to handle app initialization
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if intro has been seen
    final seenIntro = prefs.getBool('seenIntro') ?? false;

    // Check if user is logged in
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Get stored user data
    final userJson = prefs.getString('userData');

    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLoggedIn && userJson != null) {
      // User is logged in, restore session and go directly to main screen (home page)
      try {
        final userData = Map<String, dynamic>.from(jsonDecode(userJson));
        UserSession.setUser(userData);
        GlobalVariables.currentIndex = 0; // Set to home tab
        Navigator.pushReplacementNamed(context, '/main');
      } catch (e) {
        // If there's an error parsing user data, go to login
        await prefs.remove('isLoggedIn');
        await prefs.remove('userData');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (!seenIntro) {
      // First time user, show intro
      Navigator.pushReplacementNamed(context, '/intro1');
    } else {
      // User has seen intro but not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF334E7B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Icon(Icons.sign_language, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'exPress',
              style: GoogleFonts.robotoMono(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
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
    _currentIndex = widget.setIndex; // Use the passed index
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
      GlobalVariables.currentIndex = index; // Update global variable
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
            icon: Icon(Icons.menu_book_outlined, size: 30),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_3_outlined, size: 30),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
