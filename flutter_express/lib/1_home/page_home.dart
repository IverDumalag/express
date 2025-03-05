import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../0_components/help_widget.dart';
import 'popup_home_welcome.dart';
import 'waving_hand.dart';
import 'spinning_star.dart';
import '../main.dart';
import '../global_variables.dart';
import 'home_cards.dart';
import '../00_services/database_services.dart';
import '../00_services/file_search_services.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluid LED Lighting App',
      home: Home(onRefresh: () {}),
    );
  }
}

class Home extends StatefulWidget {
  final VoidCallback onRefresh;

  Home({required this.onRefresh});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final Color cardColor = const Color(0xFF334E7B);

  String greetingMessage = '';

  late final PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  final int _numSlides = 3;

  bool _popupShown = false;
  bool _needsRefresh = true;

  @override
  void initState() {
    super.initState();
    _updateGreetingMessage();
    _pageController = PageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _popupShown = prefs.getBool('popupShown') ?? false;
      if (!_popupShown) {
        _showPopupNotice(context);
      }
    });

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      int nextPage = _currentPage + 1;
      if (nextPage >= _numSlides) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _updateGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage = 'Good Morning!';
    } else if (hour < 17) {
      greetingMessage = 'Good Afternoon!';
    } else {
      greetingMessage = 'Good Evening!';
    }
  }

  void _showPopupNotice(BuildContext context) async {
    WelcomePopup.show(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('popupShown', true);
  }

  double scaleFactor(BuildContext context) {
    final baseWidth = 375.0;
    return MediaQuery.of(context).size.width / baseWidth;
  }

  Future<void> _showAddPhraseDialog(BuildContext context) async {
    final TextEditingController wordsController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Phrase'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: wordsController,
                  decoration: InputDecoration(labelText: 'Words'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                final filePath = await FileSearchService.findBestMatchFile(
                    wordsController.text, 'assets/dataset/');
                debugPrint('here: $filePath');

                _databaseService.addPhrase(
                    wordsController.text, 0, filePath ?? '');
                setState(() => _needsRefresh = true);
                Navigator.pop(context);
                widget.onRefresh();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleFavorite(String entryId, bool isFavorite) async {
    await _databaseService.updateFavorite(entryId, isFavorite ? 1 : 0);
    setState(() {
      _needsRefresh = true;
    });
  }

  Future<void> _deletePhrase(String entryId) async {
    await _databaseService.deletePhrase(entryId);
    setState(() {
      _needsRefresh = true;
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final scale = scaleFactor(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(scale),
                SizedBox(height: 40 * scale),
                Row(
                  children: [
                    _buildSectionTitle("Favorites", scale),
                    BlinkingStarIcon(scale: scale),
                  ],
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _needsRefresh ? _databaseService.getPhrases() : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      _needsRefresh = false;
                      final favoritePhrases = snapshot.data!
                          .where((phrase) => phrase['favorite'] == 1)
                          .toList();
                      if (favoritePhrases.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: Container(
                            margin: EdgeInsets.only(top: 10 * scale),
                            color: Colors.grey.withOpacity(0.5),
                            child: Text(
                              'Still Empty Nothing to be Found Here ^_^',
                              style: TextStyle(
                                fontSize: 18 * scale,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }
                      return Favorite_Words_Phrases_Cards(
                        data: favoritePhrases,
                        cardColor: cardColor,
                        scale: scale,
                        onFavoriteToggle: _toggleFavorite,
                        onDelete: _deletePhrase,
                      );
                    }
                  },
                ),
                SizedBox(height: 30 * scale),
                Row(
                  children: [
                    _buildSectionTitle("Words/Phrases", scale),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _showAddPhraseDialog(context),
                    ),
                    HelpIconWidget(
                      helpTitle: 'How to Use',
                      helpText:
                          'This is the homepage where you will see your favorites, words, and phrases. You can navigate through the cards and explore more.',
                    ),
                  ],
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _needsRefresh ? _databaseService.getPhrases() : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      _needsRefresh = false;
                      final allPhrases = snapshot.data!;
                      if (allPhrases.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: Container(
                            margin: EdgeInsets.only(top: 10 * scale),
                            color: Colors.grey.withOpacity(0.5),
                            child: Text(
                              'Still Empty Nothing to be Found Here ^_^',
                              style: TextStyle(
                                fontSize: 18 * scale,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }
                      return Words_Phrases_Cards(
                        data: allPhrases,
                        cardColor: cardColor,
                        scale: scale,
                        onFavoriteToggle: _toggleFavorite,
                        onDelete: _deletePhrase,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      height: 300 * scale,
      decoration: BoxDecoration(
        color: Color(0xFF2E5C9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(230 * scale),
          bottomRight: Radius.circular(230 * scale),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20 * scale,
            top: 60 * scale,
            child: Text(
              greetingMessage,
              style: TextStyle(
                fontSize: 28 * scale,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Positioned(
            left: 20 * scale,
            top: 110 * scale,
            right: 20 * scale,
            child: Container(
              height: 150 * scale,
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1 * scale,
                    blurRadius: 6 * scale,
                    offset: Offset(0, 3 * scale),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildSlide('Welcome to ex', 'Press!', scale),
                      _buildSlide('Discover', 'New Features!', scale),
                      _buildSlide('Stay', 'Connected!', scale),
                    ],
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: _buildPageIndicator(scale),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_numSlides, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2 * scale),
          width: 8 * scale,
          height: 8 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildSlide(String text1, String text2, double scale) {
    return GestureDetector(
      onTap: () {
        if (text1 == 'Discover' && text2 == 'New Features!') {
          GlobalVariables.currentIndex = 1;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(setIndex: 1)),
          );
        } else if (text1 == 'Stay' && text2 == 'Connected!') {
          GlobalVariables.currentIndex = 2;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(setIndex: 2)),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text1,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            text2,
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: 'Inter',
            ),
          ),
          Spacer(),
          WavingHandIcon(scale: scale),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 10 * scale,
            child: Container(
              height: 40 * scale,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2 * scale,
                    blurRadius: 5 * scale,
                    offset: Offset(0, 3 * scale),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20 * scale, vertical: 10 * scale),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 25 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
