import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final Color backgroundColor;
  final Color shadowColor;
  final TextStyle? questionStyle;
  final TextStyle? answerStyle;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    this.backgroundColor = Colors.white,
    this.shadowColor = const Color(0x33000000),
    this.questionStyle,
    this.answerStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style:
            questionStyle ??
            GoogleFonts.robotoMono(
              fontWeight: FontWeight.bold,
              color: Color(0xFF334E7B),
            ),
      ),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
            child: Text(
              answer,
              style: answerStyle ?? GoogleFonts.robotoMono(
                color: Color(0xFF334E7B),
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.justify,
            ),
        ),
      ],
    );
  }
}
