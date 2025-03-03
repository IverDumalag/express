import 'package:flutter/material.dart';
import 'dart:math' as math;

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
