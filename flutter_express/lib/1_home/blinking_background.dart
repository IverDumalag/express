import 'dart:math' as math;
import 'package:flutter/material.dart';

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
        child: Stack(
          children: List.generate(widget.itemCount, (index) => BlinkingItem()),
        ),
      ),
    );
  }
}

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
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationMs));
    _animation = Tween<double>(begin: 0.0, end: 4.0).animate(
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
                      color: const Color.fromARGB(255, 211, 211, 211),
                      fontSize: 35, // Increased size
                      fontWeight: FontWeight.bold),
                )
              : Icon(
                  iconData,
                  color: const Color.fromARGB(255, 211, 211, 211),
                  size: 35, // Increased size
                ),
        ),
      ),
    );
  }
}
