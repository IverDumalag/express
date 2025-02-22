import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluid LED Lighting App',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> cardTitles = ["Hello", "Love", "Happy", "Cute", "Sorry"];
  final Color cardColor = const Color(0xFF334E7B);

  final List<String> phrases = [
    "Hello",
    "Thank You",
    "Sorry",
    "Good Morning",
    "Good Night",
    "Please",
    "How are you?",
    "Yes",
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

  void _showPopupNotice(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Popup",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334E7B),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "This is the homepage where you will see your favorites, words, and phrases. You can navigate through the cards and explore more.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF334E7B),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Got it"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1,
            child: child,
          ),
        );
      },
    );
  }

  /// Helper: compute a scale factor based on a base width (375 is the medium screen width).
  double scaleFactor(BuildContext context) {
    final baseWidth = 375.0;
    return MediaQuery.of(context).size.width / baseWidth;
  }

  @override
  Widget build(BuildContext context) {
    final scale = scaleFactor(context);
    return Scaffold(
      // Use a transparent background so our blinking background shows through.
      backgroundColor: Colors.transparent,
      // Wrap your main content in a Stack with the blinking background below.
      body: Stack(
        children: [
          // The animated background widget.
          BlinkingBackground(itemCount: 15),
          // Main scrollable content.
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
                _buildScrollableCards(context, scale),
                SizedBox(height: 30 * scale),
                Row(
                  children: [
                    _buildSectionTitle("Words/Phrases", scale),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.help,
                          size: 30 * scale, color: Color(0xFF334E7B)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20 * scale),
                              ),
                              backgroundColor: Colors.blueGrey[50],
                              title: Text(
                                'How to Use',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334E7B),
                                  fontSize: 18 * scale,
                                ),
                              ),
                              content: Text(
                                'This is the homepage where you will see your favorites, words, and phrases. You can navigate through the cards and explore more.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF334E7B),
                                  fontSize: 16 * scale,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                        color: Color(0xFF334E7B),
                                        fontSize: 16 * scale),
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
                _buildPhrasesGrid(context, scale),
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

  Widget _buildScrollableCards(BuildContext context, double scale) {
    return SizedBox(
      height: 250 * scale,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
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
                    scale: scale,
                  ),
                ),
              );
            },
            child: Container(
              width: 180 * scale,
              margin: EdgeInsets.only(right: 10 * scale),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15 * scale),
                border: Border.all(color: Color(0xFF051B4E), width: 2 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2 * scale,
                    blurRadius: 5 * scale,
                    offset: Offset(0, 3 * scale),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      cardTitles[index],
                      style: TextStyle(
                        fontSize: 20 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: Row(
                      children: [
                        InteractiveSpeakerIcon(scale: scale),
                        SizedBox(width: 5 * scale),
                        InteractiveStarIcon(scale: scale),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8 * scale,
                    right: 8 * scale,
                    child: Container(
                      width: 20 * scale,
                      height: 20 * scale,
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

  Widget _buildPhrasesGrid(BuildContext context, double scale) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10 * scale,
          mainAxisSpacing: 10 * scale,
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
                    scale: scale,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15 * scale),
                border: Border.all(color: Color(0xFF051B4E), width: 2 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2 * scale,
                    blurRadius: 5 * scale,
                    offset: Offset(0, 3 * scale),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      phrases[index],
                      style: TextStyle(
                        fontSize: 20 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8 * scale,
                    right: 8 * scale,
                    child: Row(
                      children: [
                        InteractiveSpeakerIcon(scale: scale),
                        SizedBox(width: 5 * scale),
                        InteractiveStarIcon(scale: scale),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8 * scale,
                    right: 8 * scale,
                    child: Container(
                      width: 20 * scale,
                      height: 20 * scale,
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

// -------------------------
// Blinking Background Widgets
// -------------------------

class BlinkingBackground extends StatefulWidget {
  final int itemCount;
  BlinkingBackground({this.itemCount = 10});

  @override
  _BlinkingBackgroundState createState() => _BlinkingBackgroundState();
}

class _BlinkingBackgroundState extends State<BlinkingBackground> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        // Allow touches to pass through.
        child: Stack(
          children:
              List.generate(widget.itemCount, (index) => BlinkingItem()),
        ),
      ),
    );
  }
}

// Each blinking item now uses a random start delay and duration,
// plus a combined fade and scale transition for a smoother effect.
// The font/icon size and position are adjusted for a larger appearance.
class BlinkingItem extends StatefulWidget {
  @override
  _BlinkingItemState createState() => _BlinkingItemState();
}

class _BlinkingItemState extends State<BlinkingItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Whether to show a letter or an icon.
  bool showLetter = true;
  String letter = "A";
  IconData? iconData;
  double left = 0;
  double top = 0;

  final List<String> letters =
      List.generate(26, (index) => String.fromCharCode(index + 65));
  // Updated icon list: music and ear/speaker icons only.
  final List<IconData> icons = [
    Icons.music_note,
    Icons.headset,
    Icons.hearing,
    Icons.speaker,
  ];

  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    // Set initial random properties after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setRandomProperties();
      setState(() {});
    });
    // Randomize duration between 1.5 to 3 seconds.
    final durationMs = 1500 + random.nextInt(1500);
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: durationMs));
    _animation = Tween<double>(begin: 0.0, end: 7.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    // Start with a random delay to avoid synchronization.
    Future.delayed(Duration(milliseconds: random.nextInt(1500)), () {
      if (mounted) _controller.forward();
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _setRandomProperties();
        _controller.forward();
      }
    });
  }

  void _setRandomProperties() {
    final size = MediaQuery.of(context).size;
    // Adjusted for larger items (subtract 80 instead of 50).
    left = random.nextDouble() * (size.width - 80);
    top = random.nextDouble() * (size.height - 80);
    // Randomly choose between letter and icon.
    showLetter = random.nextBool();
    if (showLetter) {
      letter = letters[random.nextInt(letters.length)];
    } else {
      iconData = icons[random.nextInt(icons.length)];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _animation,
        child: ScaleTransition(
          scale: _animation,
          child: showLetter
              ? Text(
                  letter,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 230, 230, 230),
                      fontSize: 35, // Increased size
                      fontWeight: FontWeight.bold),
                )
              : Icon(
                  iconData,
                  color: const Color.fromARGB(255, 230, 230, 230),
                  size: 35, // Increased size
                ),
        ),
      ),
    );
  }
}

// -------------------------
// Other Animated Widgets (unchanged)
// -------------------------

class WavingHandIcon extends StatefulWidget {
  final double scale;
  const WavingHandIcon({Key? key, required this.scale}) : super(key: key);

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
      duration: Duration(seconds: 1),
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
      child:
          Icon(Icons.waving_hand, color: Colors.orange, size: 50 * widget.scale),
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
  final double scale;
  const BlinkingStarIcon({Key? key, required this.scale}) : super(key: key);

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
      duration: Duration(seconds: 1),
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
          angle: _animation.value * 2.0 * math.pi,
          child: Icon(
            Icons.star,
            color: Colors.yellow,
            size: 30 * widget.scale,
            shadows: [
              Shadow(
                color: Color(0xFF334E7B),
                blurRadius: 2 * widget.scale,
                offset: Offset(0, 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InteractiveStarIcon extends StatefulWidget {
  final double scale;
  const InteractiveStarIcon({Key? key, required this.scale}) : super(key: key);

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
        size: 30 * widget.scale,
      ),
    );
  }
}

class InteractiveSpeakerIcon extends StatefulWidget {
  final double scale;
  const InteractiveSpeakerIcon({Key? key, required this.scale}) : super(key: key);

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
        });
      },
      child: Icon(
        isLoud ? Icons.speaker : Icons.speaker_phone,
        color: Colors.white,
        size: 30 * widget.scale,
      ),
    );
  }
}

class CardDetailScreen extends StatefulWidget {
  final String title;
  final Color color;
  final int index;
  final List<String> items;
  final double scale;

  const CardDetailScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.index,
    required this.items,
    required this.scale,
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
        title: Text(widget.items[currentIndex],
            style: TextStyle(fontSize: 20 * widget.scale)),
        backgroundColor: widget.color,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 250 * widget.scale,
              width: 250 * widget.scale,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20 * widget.scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2 * widget.scale,
                    blurRadius: 5 * widget.scale,
                    offset: Offset(0, 3 * widget.scale),
                  ),
                ],
                border:
                    Border.all(color: Color(0xFF051B4E), width: 2 * widget.scale),
              ),
              child: Center(
                child: Text(
                  widget.items[currentIndex],
                  style: TextStyle(
                    fontSize: 30 * widget.scale,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30 * widget.scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: currentIndex > 0 ? _goToPrevious : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(
                      fontSize: 16 * widget.scale, fontFamily: 'Inter'),
                ),
                child: Text("Back"),
              ),
              ElevatedButton(
                onPressed:
                    currentIndex < widget.items.length - 1 ? _goToNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: TextStyle(
                      fontSize: 16 * widget.scale, fontFamily: 'Inter'),
                ),
                child: Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
