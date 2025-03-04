import 'package:flutter/material.dart';

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final Color backgroundColor;
  final Color shadowColor;
  final TextStyle questionStyle;
  final TextStyle answerStyle;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    this.backgroundColor = Colors.white,
    this.shadowColor = const Color(0x33000000),
    this.questionStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.answerStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: questionStyle),
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
            style: answerStyle,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
