import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> cardTitles = ["Hello", "Love", "Happy", "Cute", "Sorry"];
  final Color cardColor = const Color(0xFF334E7B);

  final List<String> phrases = [
    "Hello", "Thank You", "Sorry", "Good Morning",
    "Good Night", "Please", "How are you?", "Yes",
  ];

  String greetingMessage = '';

  // Fields for the auto slider.
  late final PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  final int _numSlides = 3; // Total number of slides

  bool _popupShown = false; // flag to show popup only once

  @override
  void initState() {
    super.initState();
    _updateGreetingMessage();
    _pageController = PageController(initialPage: _currentPage);

    // Show popup once after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_popupShown) {
        _showPopupNotice(context);
        _popupShown = true;
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

  @override
  Widget build(BuildContext context) {
    // Note: _showPopupNotice is now only called in initState.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            Row(
              children: [
                _buildSectionTitle("Favorites"),
                BlinkingStarIcon(),
              ],
            ),
            _buildScrollableCards(context),
            const SizedBox(height: 30),
            Row(
              children: [
                _buildSectionTitle("Words/Phrases"),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.help, size: 30, color: Color(0xFF334E7B)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blueGrey[50],
                          title: Text(
                            'How to Use',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334E7B),
                            ),
                          ),
                          content: Text(
                            'This is the homepage where you will see your favorites, words, and phrases. You can navigate through the cards and explore more.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF334E7B),
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                'Close',
                                style: TextStyle(color: Color(0xFF334E7B)),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            _buildPhrasesGrid(context),
          ],
        ),
      ),
    );
  }

  void _showPopupNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.blueGrey[50],
          title: Text(
            'Welcome!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: Color(0xFF334E7B),
            ),
          ),
          content: Text(
            'This is the homepage where you will see your favorites, words, and phrases. You can navigate through the cards and explore more.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF334E7B),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF334E7B)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF2E5C9A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(230),
          bottomRight: Radius.circular(230),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 60,
            child: Text(
              greetingMessage,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 110,
            right: 20,
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
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
                      _buildSlide('Welcome to ex', 'Press!'),
                      _buildSlide('Discover', 'New Features!'),
                      _buildSlide('Stay', 'Connected!'),
                    ],
                  ),
                  // Page indicator at the bottom-right.
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildPageIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_numSlides, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }

  // Modified _buildSlide now wraps its content in a GestureDetector.
  Widget _buildSlide(String text1, String text2) {
    return GestureDetector(
      onTap: () {
        if (text1 == 'Discover' && text2 == 'New Features!') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignToTextScreen()),
          );
        } else if (text1 == 'Stay' && text2 == 'Connected!') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AudioTextSignScreen()),
          );
        }
        // Optionally add behavior for other slides.
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text1,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            text2,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          WavingHandIcon(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 10,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 25,
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

  Widget _buildScrollableCards(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: cardTitles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: cardTitles[index],
                    color: cardColor,
                    index: index,
                    items: cardTitles,
                  ),
                ),
              );
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF051B4E), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      cardTitles[index],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: const [
                        InteractiveSpeakerIcon(),
                        SizedBox(width: 5),
                        InteractiveStarIcon(),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhrasesGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: phrases.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(
                    title: phrases[index],
                    color: cardColor,
                    index: index,
                    items: phrases,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF051B4E), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      phrases[index],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: const [
                        InteractiveSpeakerIcon(),
                        SizedBox(width: 5),
                        InteractiveStarIcon(),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WavingHandIcon extends StatefulWidget {
  const WavingHandIcon({Key? key}) : super(key: key);

  @override
  _WavingHandIconState createState() => _WavingHandIconState();
}

class _WavingHandIconState extends State<WavingHandIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: const Icon(Icons.waving_hand, color: Colors.orange, size: 50),
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
    );
  }
}

class BlinkingStarIcon extends StatefulWidget {
  const BlinkingStarIcon({Key? key}) : super(key: key);

  @override
  _BlinkingStarIconState createState() => _BlinkingStarIconState();
}

class _BlinkingStarIconState extends State<BlinkingStarIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2.0 * 3.141592653589793,
          child: const Icon(
            Icons.star,
            color: Colors.yellow,
            size: 30,
            shadows: [
              Shadow(
                color: Color(0xFF334E7B),
                blurRadius: 2,
                offset: Offset(0, 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardDetailScreen extends StatefulWidget {
  final String title;
  final Color color;
  final int index;
  final List<String> items;

  const CardDetailScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.index,
    required this.items,
  }) : super(key: key);

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  void _goToNext() {
    if (currentIndex < widget.items.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color,
      appBar: AppBar(
        title: Text(widget.items[currentIndex]),
        backgroundColor: widget.color,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Color(0xFF051B4E), width: 2),
              ),
              child: Center(
                child: Text(
                  widget.items[currentIndex],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: currentIndex > 0 ? _goToPrevious : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
              ElevatedButton(
                onPressed: currentIndex < widget.items.length - 1 ? _goToNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontFamily: 'Inter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InteractiveStarIcon extends StatefulWidget {
  const InteractiveStarIcon({Key? key}) : super(key: key);

  @override
  _InteractiveStarIconState createState() => _InteractiveStarIconState();
}

class _InteractiveStarIconState extends State<InteractiveStarIcon> {
  bool isStarred = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isStarred = !isStarred;
        });
      },
      child: Icon(
        isStarred ? Icons.star : Icons.star_border,
        color: Colors.yellow,
        size: 30,
      ),
    );
  }
}

class InteractiveSpeakerIcon extends StatefulWidget {
  const InteractiveSpeakerIcon({Key? key}) : super(key: key);

  @override
  _InteractiveSpeakerIconState createState() => _InteractiveSpeakerIconState();
}

class _InteractiveSpeakerIconState extends State<InteractiveSpeakerIcon> {
  bool isLoud = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLoud = !isLoud;
          // Insert logic to switch to loud speaker mode if needed.
        });
      },
      child: Icon(
        isLoud ? Icons.speaker : Icons.speaker_phone,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

// New screen: Sign to Text.
class SignToTextScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign to Text"),
        backgroundColor: Color(0xFF334E7B),
      ),
      body: Center(
        child: Text(
          "This is the Sign to Text page.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// New screen: Audio/Text to Sign.
class AudioTextSignScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio/Text to Sign"),
        backgroundColor: Color(0xFF334E7B),
      ),
      body: Center(
        child: Text(
          "This is the Audio/Text to Sign page.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
