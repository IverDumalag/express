import 'package:flutter/material.dart';

class WavingHandIcon extends StatefulWidget {
  final double scale;
  const WavingHandIcon({super.key, required this.scale});

  @override
  State<WavingHandIcon> createState() => _WavingHandIconState();
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
      builder: (context, child) {
        return Transform.rotate(
          angle: -_animation.value, // Animation on the other side
          child: Image.asset(
            'assets/images/wavinghand.png', // Place your image in assets/images/
            width: 50 * widget.scale,
            height: 50 * widget.scale,
          ),
        );
      },
    );
  }
}